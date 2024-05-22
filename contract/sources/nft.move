module aptos_count::nft {
    use std::signer;
    use std::string;
    use std::string::String;
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
    #[test_only]
    use aptos_token_objects::property_map;

    friend aptos_count::fibonacci;
    friend aptos_count::prime_number;
    friend aptos_count::linear;

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

    fun init_module(owner: &signer) {
        let owner_address = signer::address_of(owner);
        let owner_constructor_ref = &object::create_object(owner_address);
        let owner_extend_ref = object::generate_extend_ref(owner_constructor_ref);

        move_to(owner, NftCollectionCreator {
            extend_ref: owner_extend_ref
        });
    }

    public(friend) fun create_collection(
        collection_name: String,
        description: String,
        max_supply: u64,
        uri: String
    ) acquires NftCollectionCreator {
        let extend_ref = &borrow_global<NftCollectionCreator>(@aptos_count).extend_ref;
        let signer = &object::generate_signer_for_extending(extend_ref);

        aptos_token::create_collection(
            signer,
            description,
            max_supply,
            collection_name,
            uri,
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

    public(friend) fun mint(
        to_user: address,
        collection_name: String,
        description: String,
        uri: String,
        nft_name: String,
        value: u128,
        sequence_index: u128): Object<AptosToken> acquires NftCollectionCreator {
        let extend_ref = &borrow_global<NftCollectionCreator>(@aptos_count).extend_ref;
        let signer = &object::generate_signer_for_extending(extend_ref);

        let minted_timestamp = timestamp::now_microseconds();

        let nft = aptos_token::mint_token_object(
            signer,
            collection_name,
            description,
            nft_name,
            uri,
            vector[],
            vector[],
            vector[],
        );

        aptos_token::add_typed_property(signer, nft, string::utf8(b"Value"), value);
        aptos_token::add_typed_property(signer, nft, string::utf8(b"Minted at"), minted_timestamp);
        aptos_token::add_typed_property(signer, nft, string::utf8(b"Sequence number"), sequence_index);

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

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_nft_mint(framework: &signer, user_1: &signer, user_2: &signer) acquires NftCollectionCreator {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);
        let user_1_address= signer::address_of(user_1);
        let user_2_address= signer::address_of(user_2);
        account::create_account_for_test(user_1_address);
        account::create_account_for_test(user_2_address);

        let collection_name = string::utf8(b"collection");

        init_module(owner);
        create_collection(
            collection_name,
            string::utf8(b"description"),
            100,
            string::utf8(b"uri"),
        );

        let nft_object = mint(
            user_1_address,
            collection_name,
            string::utf8(b"description"),
            string::utf8(b"uri"),
            string::utf8(b"nft name"),
            100,
            1
        );

        assert!(property_map::read_u128(&nft_object, &string::utf8(b"Value")) == 100, 1);
        assert!(object::is_owner(nft_object, user_1_address), 1);
        assert!(object::is_owner(nft_object, user_2_address) == false, 1);

        let all_emitted_events = &emitted_events<CountNftMintEvent>();
        assert!(vector::length(all_emitted_events) == 1, 2);
    }

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_nft_mint_multi_collection(framework: &signer, user_1: &signer, user_2: &signer) acquires NftCollectionCreator {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);
        let user_1_address= signer::address_of(user_1);
        let user_2_address= signer::address_of(user_2);
        account::create_account_for_test(user_1_address);
        account::create_account_for_test(user_2_address);

        let collection_name_1 = string::utf8(b"collection_1");
        let collection_name_2 = string::utf8(b"collection_2");

        init_module(owner);

        create_collection(
            collection_name_1,
            string::utf8(b"description"),
            100,
            string::utf8(b"uri"),
        );

        create_collection(
            collection_name_2,
            string::utf8(b"description"),
            100,
            string::utf8(b"uri"),
        );

        let nft_object = mint(
            user_1_address,
            collection_name_1,
            string::utf8(b"description"),
            string::utf8(b"uri"),
            string::utf8(b"nft name"),
            100,
            1
        );

        assert!(property_map::read_u128(&nft_object, &string::utf8(b"Value")) == 100, 1);
        assert!(object::is_owner(nft_object, user_1_address), 1);
        assert!(object::is_owner(nft_object, user_2_address) == false, 1);

        let nft_object = mint(
            user_2_address,
            collection_name_2,
            string::utf8(b"description 2"),
            string::utf8(b"uri 2"),
            string::utf8(b"nft name 2"),
            321,
            1
        );

        assert!(property_map::read_u128(&nft_object, &string::utf8(b"Value")) == 321, 2);
        assert!(object::is_owner(nft_object, user_1_address) == false, 2);
        assert!(object::is_owner(nft_object, user_2_address), 2);

        let all_emitted_events = &emitted_events<CountNftMintEvent>();
        assert!(vector::length(all_emitted_events) == 2, 2);
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