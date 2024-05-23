module aptos_count::prime_number {
    use std::string;
    use std::string::String;
    use aptos_std::smart_vector;
    use aptos_std::smart_vector::SmartVector;
    use aptos_std::string_utils;
    #[test_only]
    use std::signer;
    #[test_only]
    use std::vector;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_framework::timestamp;
    #[test_only]
    use aptos_count::utils;
    #[test_only]
    use aptos_count::utils::iterate_with_index;

    friend aptos_count::count;

    const COLLECTION_NAME: vector<u8> = b"Prime Number";
    const DESCRIPTION: vector<u8>  = b"a number that can only be divided by itself and 1 without remainders";
    const IMAGE_URI: vector<u8>  = b"https://i0.wp.com/mymathresources.com/wp-content/uploads/2020/06/Prime-Numbers-Poster-3.jpg?resize=800%2C533&ssl=1";
    const MAX_SUPPLY: u64 = 664579;

    struct CollectorOwner has key, store {
        timestamp_us: u64,
        user: address,
        value: u128,
        index: u128,
    }

    struct PrimeNumberCollectionMetadata has key, store, drop {
        name: String,
        description: String,
        uri: String,
        max_supply: u64
    }

    struct PrimeNumberCollection has key, store {
        owners: SmartVector<CollectorOwner>,
        next_index: u128,
    }

    fun init_module(owner: &signer) {
        move_to(owner, PrimeNumberCollection {
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

    public(friend) fun validate_and_mint(user: address, value: u128, timestamp_us: u64): bool acquires PrimeNumberCollection {
        let next_index  = get_next_index();
        let next_value = get_next_value();
        let is_next_value = next_value == value;

        if (is_next_value) {
            let collection = borrow_global_mut<PrimeNumberCollection>(@aptos_count);

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
    public fun get_collection_description(): PrimeNumberCollectionMetadata {
        return PrimeNumberCollectionMetadata {
            name: string::utf8(COLLECTION_NAME),
            description: string::utf8(DESCRIPTION),
            uri: string::utf8(IMAGE_URI),
            max_supply: MAX_SUPPLY,
        }
    }

    public(friend) fun get_next_index(): u128 acquires PrimeNumberCollection {
        let collection = borrow_global<PrimeNumberCollection>(@aptos_count);
        collection.next_index
    }

    #[view]
    public(friend) fun get_next_value(): u128 acquires PrimeNumberCollection {
        let collection = borrow_global<PrimeNumberCollection>(@aptos_count);
        get_value(collection.next_index)
    }

    fun get_value(n: u128): u128 {
        if (n == 0) return 2;

        let count = 0;
        let num = 2;
        let n = n + 1;

        while (count < n) {
            if (is_prime(num)) {
                count = count + 1;

                if (count == n) {
                    return num
                }
            };

            num = num + 1;
        };

        num
    }

    fun is_prime(n: u128): bool {
        if (n <= 1) return false;

        for (i in 2..n) {
            if (n % i == 0) {
                return false
            }
        };

        true
    }

    #[test_only]
    public fun init_module_for_testing(owner: &signer) {
        init_module(owner);
    }

    #[test_only]
    fun increment_next_index() acquires PrimeNumberCollection {
        let collection = borrow_global_mut<PrimeNumberCollection>(@aptos_count);
        collection.next_index = collection.next_index + 1;
    }

    #[test]
    public fun test_get_value() {
        let expected = vector[
            2,
            3,
            5,
            7,
            11,
            13,
            17,
            19,
            23,
            29
        ];

        utils::iterate_with_index(10, |index| {
            let expected = *vector::borrow(&expected, index);
            let index = (index as u128);
            let actual = get_value(index);

            assert!(actual == expected, 1);
        });
    }

    #[test(framework = @0x1)]
    public fun test_get_next_value(framework: &signer) acquires PrimeNumberCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        aptos_count::nft::init_module_for_testing(owner);
        init_module(owner);

        let expected = vector[
            2,
            3,
            5,
            7,
            11
        ];

        iterate_with_index(5, |i| {
            let index = get_next_index();
            let value = get_next_value();

            let expected_value = *vector::borrow(&expected, i);
            assert!(expected_value == value, 1);
            assert!(index == (i as u128), 2);
            increment_next_index();
        });
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_validate_and_mint_with_prime_number_sequence(framework: &signer, user_1: &signer) acquires PrimeNumberCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        let user_1_address = signer::address_of(user_1);
        account::create_account_for_test(user_1_address);

        aptos_count::nft::init_module_for_testing(owner);
        init_module(owner);

        assert!(get_next_index() == 0, 1);

        let expected = vector[
            false,
            false,
            true,
            true,
            false,
            true,
            false,
            true,
            false,
            false,
        ];

        utils::iterate_with_index(10, |index| {
            let expected = *vector::borrow(&expected, index);
            let actual = validate_and_mint(user_1_address, (index as u128), 0);
            assert!(actual == expected, 1);
        })
    }
}