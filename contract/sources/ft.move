module aptos_counter::ft {
    use std::object;
    use std::option;
    use std::string;

    use aptos_framework::fungible_asset;
    use aptos_framework::fungible_asset::{TransferRef, BurnRef, MintRef, Metadata};
    use aptos_framework::object::Object;
    use aptos_framework::primary_fungible_store;

    friend aptos_counter::counter;

    const ASSETS_SYMBOL: vector<u8> = b"CNTR";
    const ASSETS_NAME: vector<u8> = b"COUNTER";
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
            string::utf8(b"https://static.thenounproject.com/png/304008-200.png"),
            string::utf8(b"https://timx.co")
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
        object::create_object_address(&@aptos_counter, ASSETS_SYMBOL)
    }

    #[view]
    public fun get_ft_metadata(): Object<Metadata> {
        object::address_to_object(get_ft_address())
    }

    public(friend) fun is_exists(): bool {
        exists<ManagedFT>(get_ft_address())
    }
}