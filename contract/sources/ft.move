module aptos_count::ft {
    use std::object;
    use std::option;
    use std::string;

    use aptos_framework::fungible_asset;
    use aptos_framework::fungible_asset::{TransferRef, BurnRef, MintRef, Metadata};
    use aptos_framework::object::Object;
    use aptos_framework::primary_fungible_store;
    #[test_only]
    use std::signer;
    #[test_only]
    use aptos_framework::account;

    friend aptos_count::count;

    const ASSETS_SYMBOL: vector<u8> = b"CNT";
    const ASSETS_NAME: vector<u8> = b"COUNT";
    const ICON_URI: vector<u8> = b"https://count.timx.co/count.svg";
    const PROJECT_URI: vector<u8> = b"https://count.timx.co";
    const MAX_SUPPLY: u128 = 1_000_000;

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct ManagedFT has key {
        transfer_ref: TransferRef,
        burn_ref: BurnRef,
        mint_ref: MintRef
    }

    fun init_module(owner: &signer) {
        let construct_ref = &object::create_named_object(owner, ASSETS_SYMBOL);

        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            construct_ref,
            option::some(MAX_SUPPLY),
            string::utf8(ASSETS_NAME),
            string::utf8(ASSETS_SYMBOL),
            0,
            string::utf8(ICON_URI),
            string::utf8(PROJECT_URI)
        );

        let mint_ref = fungible_asset::generate_mint_ref(construct_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(construct_ref);
        let burn_ref = fungible_asset::generate_burn_ref(construct_ref);
        let object_signer = &object::generate_signer(construct_ref);

        move_to(object_signer, ManagedFT {
            transfer_ref,
            burn_ref,
            mint_ref
        });
    }

    public(friend) fun mint_to(receiver: address, amount: u64) acquires ManagedFT {
        let mint_ref = &borrow_global<ManagedFT>(get_ft_address()).mint_ref;
        let receiver_wallet = primary_fungible_store::ensure_primary_store_exists(receiver, get_ft_metadata());

        fungible_asset::mint_to(mint_ref, receiver_wallet, amount);
    }

    #[view]
    public fun get_ft_address(): address {
        object::create_object_address(&@aptos_count, ASSETS_SYMBOL)
    }

    #[view]
    public fun get_ft_metadata(): Object<Metadata> {
        object::address_to_object(get_ft_address())
    }

    #[view]
    public fun get_balance(user: address): u64 {
        let store = primary_fungible_store::ensure_primary_store_exists(user, get_ft_metadata());
        fungible_asset::balance(store)
    }

    #[test_only]
    public fun init_module_for_testing(owner: &signer) {
        init_module(owner);
    }

    #[test(user_1 = @0x123)]
    public fun test_get_balance(user_1: &signer) acquires ManagedFT {
        let owner = &account::create_account_for_test(@aptos_count);
        account::create_account_for_test(signer::address_of(user_1));
        let user_1_address = signer::address_of(user_1);

        init_module(owner);

        let before_balance = get_balance(user_1_address);
        mint_to(user_1_address, 100);
        let after_balance = get_balance(user_1_address);

        assert!(before_balance == 0, 0);
        assert!(after_balance == 100, 0);
    }

    public(friend) fun is_exists(): bool {
        exists<ManagedFT>(get_ft_address())
    }
}
