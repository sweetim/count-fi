module aptos_count::linear {
    use std::string;
    use std::string::String;
    use aptos_std::smart_vector;
    use aptos_std::smart_vector::SmartVector;
    use aptos_std::string_utils;
    #[test_only]
    use std::signer;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_framework::timestamp;
    #[test_only]
    use aptos_count::utils;
    #[test_only]
    use aptos_count::utils::iterate_with_index;

    friend aptos_count::count;

    const COLLECTION_NAME: vector<u8> = b"Linear";
    const DESCRIPTION: vector<u8>  = b"a sequence of numbers where the difference between every term is the same";
    const IMAGE_URI: vector<u8>  = b"https://www.radfordmathematics.com/algebra/sequences-series/difference-method-sequences/linear-sequence-formula.jpg";
    const MAX_SUPPLY: u64 = 1 << 63;

    struct CollectorOwner has key, store {
        timestamp_us: u64,
        user: address,
        value: u128,
        index: u128,
    }

    struct LinearCollectionMetadata has key, store, drop {
        name: String,
        description: String,
        uri: String,
        max_supply: u64
    }

    struct LinearCollection has key, store {
        owners: SmartVector<CollectorOwner>,
        next_index: u128,
    }

    fun init_module(owner: &signer) {
        move_to(owner, LinearCollection {
            next_index: 0,
            owners: smart_vector::new<CollectorOwner>()
        });

        let collection_description = get_collection_description();
        aptos_count::nft::create_collection(
            collection_description.name,
            collection_description.description,
            collection_description.max_supply,
            collection_description.uri
        );
    }

    public(friend) fun validate_and_mint(user: address, value: u128, timestamp_us: u64): bool acquires LinearCollection {
        let next_index  = get_next_index();
        let next_value = get_next_value();
        let is_next_value = next_value == value;

        if (is_next_value) {
            let collection = borrow_global_mut<LinearCollection>(@aptos_count);

            smart_vector::push_back(&mut collection.owners, CollectorOwner {
                timestamp_us,
                user,
                value,
                index: next_index
            });

            collection.next_index = collection.next_index + 1;

            mint_nft(user, value, next_index);
        };

        is_next_value
    }

    fun mint_nft(user: address, value: u128, next_index: u128) {
        let nft_name = string_utils::format1(&b"Prime Number - {}", value);
        let description = string_utils::format1(&b"Sequence number - {}", next_index);
        let uri = string_utils::format1(&b"https://robohash.org/{}?set=set2", value);

        aptos_count::nft::mint(
            user,
            get_collection_description().name,
            description,
            uri,
            nft_name,
            value,
            next_index);
    }

    #[view]
    public(friend) fun get_collection_description(): LinearCollectionMetadata {
        return LinearCollectionMetadata {
            name: string::utf8(COLLECTION_NAME),
            description: string::utf8(DESCRIPTION),
            uri: string::utf8(IMAGE_URI),
            max_supply: MAX_SUPPLY,
        }
    }

    public(friend) fun get_next_index(): u128 acquires LinearCollection {
        let collection = borrow_global<LinearCollection>(@aptos_count);
        collection.next_index
    }

    #[view]
    public(friend) fun get_next_value(): u128 acquires LinearCollection {
        let collection = borrow_global<LinearCollection>(@aptos_count);
        get_value(collection.next_index)
    }

    fun get_value(n: u128): u128 {
        n
    }

    #[test_only]
    public fun init_module_for_testing(owner: &signer) {
        init_module(owner);
    }

    #[test_only]
    fun increment_next_index() acquires LinearCollection {
        let collection = borrow_global_mut<LinearCollection>(@aptos_count);
        collection.next_index = collection.next_index + 1;
    }

    #[test]
    public fun test_get_value() {
        utils::iterate_with_index(100, |index| {
            assert!(get_value((index as u128)) == (index as u128), 1);
        });
    }

    #[test(framework = @0x1)]
    public fun test_get_next_value(framework: &signer) acquires LinearCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        aptos_count::nft::init_module_for_testing(owner);
        init_module(owner);

        iterate_with_index(5, |i| {
            let index = get_next_index();
            let value = get_next_value();
            let i = (i as u128);

            assert!(i == value, 1);
            assert!(i == index, 2);
            increment_next_index();
        });
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_validate_and_mint_with_fibonacci_sequence(framework: &signer, user_1: &signer) acquires LinearCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        let user_1_address = signer::address_of(user_1);
        account::create_account_for_test(user_1_address);

        aptos_count::nft::init_module_for_testing(owner);
        init_module(owner);

        assert!(get_next_index() == 0, 1);

        iterate_with_index(10, |index| {
            let actual = validate_and_mint(user_1_address, (index as u128), 0);
            assert!(actual == true, 1);
        });
    }
}