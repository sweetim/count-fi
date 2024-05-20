module aptos_count::nft {
    use std::signer;
    use std::string;
    use aptos_std::string_utils;
    use aptos_framework::event;
    use aptos_framework::object;
    use aptos_framework::object::{ExtendRef, Object};
    use aptos_framework::timestamp;
    use aptos_token_objects::aptos_token;
    use aptos_token_objects::aptos_token::AptosToken;
    #[test_only]
    use std::vector;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_framework::event::emitted_events;

    friend aptos_count::count;

    struct NftCollectionCreator has key {
        extend_ref: ExtendRef
    }

    #[event]
    struct CountNftMintEvent has key, store, drop, copy {
        timestamp_us: u64,
        user: address,
        value: u128,
        nft_address: address,
    }

    const COLLECTION_NAME: vector<u8> = b"COUNT - Fibonacci";

    fun init_module(owner: &signer) {
        let owner_address = signer::address_of(owner);
        let owner_constructor_ref = &object::create_object(owner_address);
        let owner_extend_ref = object::generate_extend_ref(owner_constructor_ref);

        move_to(owner, NftCollectionCreator {
            extend_ref: owner_extend_ref
        });

        let owner_signer = &object::generate_signer(owner_constructor_ref);

        aptos_token::create_collection(
            owner_signer,
            string::utf8(b"a collection count NFT minted using fibonacci sequence"),
            185,
            string::utf8(COLLECTION_NAME),
            string::utf8(b"https://count.timx.co/fibonacci.svg"),
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            5,
            100
        );
    }

    public(friend) fun mint(to_user: address, value: u128): Object<AptosToken> acquires NftCollectionCreator {
        let extend_ref = &borrow_global<NftCollectionCreator>(@aptos_count).extend_ref;
        let signer = &object::generate_signer_for_extending(extend_ref);

        let description = string_utils::format1(&b"fibonacci sequence number - {}", value);
        let uri = string_utils::format1(&b"https://robohash.org/{}?set=set4", value);
        let minted_timestamp = timestamp::now_microseconds();

        let nft = aptos_token::mint_token_object(
            signer,
            string::utf8(COLLECTION_NAME),
            description,
            string_utils::format1(&b"Fibonacci - {}", value),
            uri,
            vector[],
            vector[],
            vector[],
        );

        aptos_token::add_typed_property(signer, nft, string::utf8(b"Value"), value);
        aptos_token::add_typed_property(signer, nft, string::utf8(b"Minted at"), minted_timestamp);

        object::transfer(signer, nft, to_user);

        event::emit(CountNftMintEvent {
            value,
            user: to_user,
            timestamp_us: minted_timestamp,
            nft_address: object::object_address(&nft)
        });

        nft
    }

    #[test_only]
    public fun init_module_for_testing(owner: &signer) {
        init_module(owner);
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_nft_mint(framework: &signer, user_1: &signer) acquires NftCollectionCreator {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);
        let user_1_address= signer::address_of(user_1);
        account::create_account_for_test(user_1_address);

        init_module(owner);
        mint(user_1_address, 123);

        let all_emitted_events = &emitted_events<CountNftMintEvent>();
        assert!(vector::length(all_emitted_events) == 1, 2);
    }
}

// public entry fun pay_fee(owner: &signer) acquires ManagingRefs {
// coin::transfer<AptosCoin>(owner, @move_counter, 10000000);
//
// let transfer_ref = &borrow_global<ManagingRefs>(ft_address()).transfer_ref;
// let admin_primary_store = primary_fungible_store::ensure_primary_store_exists(
// @move_counter,
// ft_metadata()
// );
//
// let owner_primary_store = primary_fungible_store::ensure_primary_store_exists(
// signer::address_of(owner),
// ft_metadata()
// );
// fungible_asset::transfer_with_ref(transfer_ref, admin_primary_store, owner_primary_store, 10);
// // fungible_asset::transfer(owner, admin_primary_store, owner_primary_store, 10);
// // fungible_asset::transfer(owner, ft_metadata(), ft_metadata(), 10);
// // fungible_asset::transfer_with_ref(transfer_ref, )
// }
//
// #[view]
// public fun ft_address(): address {
// object::create_object_address(&@move_counter, ASSET_SYMBOL)
// }
//
// #[view]
// public fun ft_metadata(): Object<Metadata> {
// object::address_to_object(ft_address())
// }