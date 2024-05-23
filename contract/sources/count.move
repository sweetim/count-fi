module aptos_count::count {
    use std::timestamp;
    use std::signer;
    use std::string::String;
    use std::vector;

    use aptos_std::smart_vector;
    use aptos_std::smart_vector::SmartVector;
    use aptos_std::table;
    use aptos_std::table::Table;
    use aptos_framework::event;

    // use aptos_framework::randomness;

    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_framework::event::emitted_events;
    #[test_only]
    use aptos_count::fibonacci;

    const COUNT_ACTION_INCREMENT: u8 = 1;
    const COUNT_ACTION_DECREMENT: u8 = 2;
    const COUNT_ACTION_RANDOM: u8 = 3;

    const COLLECTION_FIBONACCI_ID: u32 = 0;
    const COLLECTION_PRIME_NUMBER_ID: u32 = 1;
    const COLLECTION_LINEAR_ID: u32 = 2;
    const COLLECTION_TYPE_COUNT: u32 = 3;

    const E_NOT_OWNER: u64 = 1;
    const E_WRONG_COLLECTION_ID: u64 = 2;

    struct CountCollection has key {
        items: Table<u32, Count>
    }

    struct Count has key, store {
        value: u128,
        records: SmartVector<CountRecord>
    }

    struct CountRecord has key, store, drop, copy {
        timestamp_us: u64,
        user: address,
        action: u8,
    }

    struct CollectionMetadata has key, store, drop {
        title: String,
        description: String,
        uri: String,
        max_supply: u64
    }

    #[event]
    struct CountRecordEvent has key, store, drop, copy {
        timestamp_us: u64,
        user: address,
        action: u8,
        value: u128
    }

    fun init_module(owner: &signer) {
        let count_collection = CountCollection {
            items: table::new()
        };

        table::add(
            &mut count_collection.items, COLLECTION_FIBONACCI_ID, Count {
                value: 0,
                records: smart_vector::new()
            });

        table::add(
            &mut count_collection.items, COLLECTION_PRIME_NUMBER_ID, Count {
            value: 0,
            records: smart_vector::new()
        });

        table::add(
            &mut count_collection.items, COLLECTION_LINEAR_ID, Count {
            value: 0,
            records: smart_vector::new()
        });

        move_to(owner, count_collection);
    }

    #[test]
    public fun test_init() acquires CountCollection {
        let owner = account::create_account_for_test(@aptos_count);
        init_module(&owner);

        for (id in 0..COLLECTION_TYPE_COUNT) {
            assert!(get_value(id) == 0, 1);
        };
    }

    public entry fun increment(user: &signer, collection_id: u32) acquires CountCollection {
        perform_action(user, collection_id, COUNT_ACTION_INCREMENT);
    }

    inline fun get_random_action(): u8 {
        // randomness::u8_range(
        //     COUNTER_ACTION_INCREMENT,
        //     COUNTER_ACTION_DECREMENT + 1)

        let is_even = timestamp::now_microseconds() % 2 == 0;
        if (is_even) COUNT_ACTION_INCREMENT else COUNT_ACTION_DECREMENT
    }

    fun perform_action(user: &signer, collection_id: u32, action: u8) acquires CountCollection {
        assert!(collection_id < COLLECTION_TYPE_COUNT, E_WRONG_COLLECTION_ID);

        let collection = borrow_global_mut<CountCollection>(@aptos_count);

        let count = table::borrow_mut(&mut collection.items, collection_id);
        let current_timestamp_us = timestamp::now_microseconds();
        let user_address = signer::address_of(user);
        let count_record = CountRecord {
            action,
            timestamp_us: current_timestamp_us,
            user: user_address
        };

        let action = if (action == COUNT_ACTION_RANDOM) get_random_action() else action;
        update_value_from_action(&mut count.value, action);
        smart_vector::push_back(&mut count.records, count_record);

        if (aptos_count::ft::is_exists()) {
            aptos_count::ft::mint_to(signer::address_of(user), 1);
        };

        if (collection_id == COLLECTION_FIBONACCI_ID) {
            aptos_count::fibonacci::validate_and_mint(user_address, count.value, current_timestamp_us);
        } else if (collection_id == COLLECTION_PRIME_NUMBER_ID) {
            aptos_count::prime_number::validate_and_mint(user_address, count.value, current_timestamp_us);
        } else if (collection_id == COLLECTION_LINEAR_ID) {
            aptos_count::linear::validate_and_mint(user_address, count.value, current_timestamp_us);
        };

        event::emit(CountRecordEvent {
            action: count_record.action,
            timestamp_us: count_record.timestamp_us,
            user: count_record.user,
            value: count.value,
        });
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_perform_action_fibonacci(framework: &signer, user_1: &signer) acquires CountCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);
        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        aptos_count::ft::init_module_for_testing(owner);
        aptos_count::nft::init_module_for_testing(owner);
        aptos_count::fibonacci::init_module_for_testing(owner);

        assert!(fibonacci::get_next_value() == 0, 1);
        perform_action(user_1, COLLECTION_FIBONACCI_ID, COUNT_ACTION_DECREMENT);
        assert!(fibonacci::get_next_value() == 1, 2);
        perform_action(user_1, COLLECTION_FIBONACCI_ID, COUNT_ACTION_INCREMENT);
        assert!(fibonacci::get_next_value() == 1, 3);
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    #[expected_failure(abort_code = E_WRONG_COLLECTION_ID, location = Self)]
    public fun test_perform_action_wrong_collection_id(framework: &signer, user_1: &signer) acquires CountCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);
        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        aptos_count::ft::init_module_for_testing(owner);
        aptos_count::nft::init_module_for_testing(owner);
        aptos_count::fibonacci::init_module_for_testing(owner);

        perform_action(user_1, 5, COUNT_ACTION_INCREMENT);
    }

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_perform_action_test_ft_balance(framework: &signer, user_1: &signer, user_2: &signer) acquires CountCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));
        account::create_account_for_test(signer::address_of(user_2));

        init_module(owner);
        aptos_count::ft::init_module_for_testing(owner);
        aptos_count::nft::init_module_for_testing(owner);
        aptos_count::fibonacci::init_module_for_testing(owner);

        let balance_user_1 = aptos_count::ft::get_balance(signer::address_of(user_1));
        let balance_user_2 = aptos_count::ft::get_balance(signer::address_of(user_2));

        assert!(0 == balance_user_1, 1);
        assert!(0 == balance_user_2, 2);

        perform_action(user_1, COLLECTION_FIBONACCI_ID, COUNT_ACTION_INCREMENT);

        let balance_user_1 = aptos_count::ft::get_balance(signer::address_of(user_1));
        let balance_user_2 = aptos_count::ft::get_balance(signer::address_of(user_2));

        assert!(1 == balance_user_1, 1);
        assert!(0 == balance_user_2, 2);
    }

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_increment_single_collection(framework: &signer, user_1: &signer, user_2: &signer) acquires CountCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));
        account::create_account_for_test(signer::address_of(user_2));

        init_module(owner);
        aptos_count::ft::init_module_for_testing(owner);
        aptos_count::nft::init_module_for_testing(owner);
        aptos_count::fibonacci::init_module_for_testing(owner);

        increment(user_1, COLLECTION_FIBONACCI_ID);
        assert!(get_value(COLLECTION_FIBONACCI_ID) == 1, 1);

        increment(user_2, COLLECTION_FIBONACCI_ID);
        assert!(get_value(COLLECTION_FIBONACCI_ID) == 2, 2);

        increment(user_1, COLLECTION_FIBONACCI_ID);
        assert!(get_value(COLLECTION_FIBONACCI_ID) == 3, 2);

        let event_length = vector::length(&emitted_events<CountRecordEvent>());
        assert!(event_length == 3, 3);
    }

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_increment_multi_collection(framework: &signer, user_1: &signer, user_2: &signer) acquires CountCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));
        account::create_account_for_test(signer::address_of(user_2));

        init_module(owner);

        aptos_count::ft::init_module_for_testing(owner);
        aptos_count::nft::init_module_for_testing(owner);
        aptos_count::fibonacci::init_module_for_testing(owner);
        aptos_count::linear::init_module_for_testing(owner);
        aptos_count::prime_number::init_module_for_testing(owner);

        increment(user_1, COLLECTION_FIBONACCI_ID);
        assert!(get_value(COLLECTION_FIBONACCI_ID) == 1, 1);
        assert!(get_value(COLLECTION_PRIME_NUMBER_ID) == 0, 2);
        assert!(get_value(COLLECTION_LINEAR_ID) == 0, 3);

        increment(user_2, COLLECTION_FIBONACCI_ID);
        assert!(get_value(COLLECTION_FIBONACCI_ID) == 2, 4);
        assert!(get_value(COLLECTION_PRIME_NUMBER_ID) == 0, 5);
        assert!(get_value(COLLECTION_LINEAR_ID) == 0, 6);

        increment(user_1, COLLECTION_PRIME_NUMBER_ID);
        assert!(get_value(COLLECTION_FIBONACCI_ID) == 2, 7);
        assert!(get_value(COLLECTION_PRIME_NUMBER_ID) == 1, 8);
        assert!(get_value(COLLECTION_LINEAR_ID) == 0, 9);

        let event_length = vector::length(&emitted_events<CountRecordEvent>());
        assert!(event_length == 3, 3);
    }

    public entry fun decrement(user: &signer, collection_id: u32) acquires CountCollection {
        perform_action(user, collection_id, COUNT_ACTION_DECREMENT);
    }

    #[test_only]
    fun change_value(signer: &signer, collection_id: u32, value: u128) acquires CountCollection {
        let user_address = signer::address_of(signer);
        assert!(exists<CountCollection>(user_address), E_NOT_OWNER);

        let collection = borrow_global_mut<CountCollection>(@aptos_count);
        let counter = table::borrow_mut(&mut collection.items, collection_id);
        counter.value = value;
    }

    #[test(user_1 = @0x123)]
    #[expected_failure]
    public fun test_change_value(user_1: &signer) acquires CountCollection {
        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        aptos_count::ft::init_module_for_testing(owner);
        aptos_count::nft::init_module_for_testing(owner);
        aptos_count::fibonacci::init_module_for_testing(owner);

        change_value(user_1, COLLECTION_FIBONACCI_ID, 1000);
        assert!(1000 == get_value(COLLECTION_FIBONACCI_ID), 1);
        assert!(0 == get_value(COLLECTION_LINEAR_ID), 2);
        assert!(0 == get_value(COLLECTION_PRIME_NUMBER_ID), 3);
    }

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_decrement_collection(framework: &signer, user_1: &signer, user_2: &signer) acquires CountCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));
        account::create_account_for_test(signer::address_of(user_2));

        init_module(owner);
        aptos_count::ft::init_module_for_testing(owner);
        aptos_count::nft::init_module_for_testing(owner);
        aptos_count::fibonacci::init_module_for_testing(owner);

        assert!(get_value(COLLECTION_FIBONACCI_ID) == 0, 0);
        change_value(owner, COLLECTION_FIBONACCI_ID, 1000);

        assert!(get_value(COLLECTION_FIBONACCI_ID) == 1000, 1);
        assert!(0 == get_value(COLLECTION_LINEAR_ID), 2);
        assert!(0 == get_value(COLLECTION_PRIME_NUMBER_ID), 3);

        decrement(user_1, COLLECTION_FIBONACCI_ID);
        assert!(get_value(COLLECTION_FIBONACCI_ID) == 999, 1);
        assert!(0 == get_value(COLLECTION_LINEAR_ID), 2);
        assert!(0 == get_value(COLLECTION_PRIME_NUMBER_ID), 3);

        decrement(user_1, COLLECTION_FIBONACCI_ID);
        assert!(get_value(COLLECTION_FIBONACCI_ID) == 998, 1);
        assert!(0 == get_value(COLLECTION_LINEAR_ID), 2);
        assert!(0 == get_value(COLLECTION_PRIME_NUMBER_ID), 3);

        decrement(user_2, COLLECTION_FIBONACCI_ID);
        assert!(get_value(COLLECTION_FIBONACCI_ID) == 997, 1);
        assert!(0 == get_value(COLLECTION_LINEAR_ID), 2);
        assert!(0 == get_value(COLLECTION_PRIME_NUMBER_ID), 3);

        decrement(user_1, COLLECTION_FIBONACCI_ID);
        assert!(get_value(COLLECTION_FIBONACCI_ID) == 996, 1);
        assert!(0 == get_value(COLLECTION_LINEAR_ID), 2);
        assert!(0 == get_value(COLLECTION_PRIME_NUMBER_ID), 3);

        let event_length = vector::length(&emitted_events<CountRecordEvent>());
        assert!(event_length == 4, 3);
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_decrement_not_fail_when_zero(framework: &signer, user_1: &signer) acquires CountCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        aptos_count::ft::init_module_for_testing(owner);
        aptos_count::nft::init_module_for_testing(owner);
        aptos_count::fibonacci::init_module_for_testing(owner);

        decrement(user_1, COLLECTION_FIBONACCI_ID);
        decrement(user_1, COLLECTION_FIBONACCI_ID);

        assert!(get_value(COLLECTION_FIBONACCI_ID) == 0, 1);
    }

    #[randomness]
    entry fun random(user: &signer, collection_id: u32) acquires CountCollection {
        perform_action(user, collection_id, COUNT_ACTION_RANDOM);
    }

    fun update_value_from_action(value: &mut u128, action: u8) {
        if (action == COUNT_ACTION_INCREMENT) {
            *value = *value + 1;
        };

        if (action == COUNT_ACTION_DECREMENT) {
            if (*value > 0) {
                *value = *value - 1;
            }
        };
    }

    #[test]
    public fun test_update_value_from_action() {
        let value: u128 = 100;

        update_value_from_action(&mut value, COUNT_ACTION_INCREMENT);
        assert!(value == 101, 1);

        update_value_from_action(&mut value, COUNT_ACTION_DECREMENT);
        assert!(value == 100, 1);
    }

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_random(framework: &signer, user_1: &signer, user_2: &signer) acquires CountCollection {
        timestamp::set_time_has_started_for_testing(framework);
        // randomness::initialize_for_testing(framework);
        // randomness::set_seed(x"0000000000000000000000000000000000000000000000000000000000000001");

        let owner = &account::create_account_for_test(@aptos_count);
        account::create_account_for_test(signer::address_of(user_1));
        account::create_account_for_test(signer::address_of(user_2));

        let actual_value = vector[];

        init_module(owner);
        aptos_count::ft::init_module_for_testing(owner);
        aptos_count::nft::init_module_for_testing(owner);
        aptos_count::fibonacci::init_module_for_testing(owner);

        vector::push_back(&mut actual_value, get_value(COLLECTION_FIBONACCI_ID));

        timestamp::update_global_time_for_test(2);
        random(user_1, COLLECTION_FIBONACCI_ID);
        vector::push_back(&mut actual_value, get_value(COLLECTION_FIBONACCI_ID));

        timestamp::update_global_time_for_test(3);
        random(user_2, COLLECTION_FIBONACCI_ID);
        vector::push_back(&mut actual_value, get_value(COLLECTION_FIBONACCI_ID));

        timestamp::update_global_time_for_test(5);
        random(user_2, COLLECTION_FIBONACCI_ID);
        vector::push_back(&mut actual_value, get_value(COLLECTION_FIBONACCI_ID));

        timestamp::update_global_time_for_test(6);
        random(user_2, COLLECTION_FIBONACCI_ID);
        vector::push_back(&mut actual_value, get_value(COLLECTION_FIBONACCI_ID));

        timestamp::update_global_time_for_test(8);
        random(user_1, COLLECTION_FIBONACCI_ID);
        vector::push_back(&mut actual_value, get_value(COLLECTION_FIBONACCI_ID));

        let expected_value: vector<u128> = vector[
            0, 1, 0, 0, 1, 2
        ];

        vector::zip(actual_value, expected_value, |a, e| assert!(a == e, 1));

        let all_emitted_events = &emitted_events<CountRecordEvent>();

        let expected = vector[
            CountRecordEvent {
                timestamp_us: 2,
                user: @0x123,
                action: 3,
                value: 1,
            },
            CountRecordEvent {
                timestamp_us: 3,
                user: @0x321,
                action: 3,
                value: 0,
            },
            CountRecordEvent {
                timestamp_us: 5,
                user: @0x321,
                action: 3,
                value: 0,
            },
            CountRecordEvent {
                timestamp_us: 6,
                user: @0x321,
                action: 3,
                value: 1,
            },
            CountRecordEvent {
                timestamp_us: 8,
                user: @0x123,
                action: 3,
                value: 2,
            }
        ];

        vector::zip_ref(all_emitted_events, &expected, |a, b| assert!(a == b, 1));
    }

    #[view]
    public fun get_value(collection_id: u32): u128 acquires CountCollection {
        assert!(collection_id < COLLECTION_TYPE_COUNT, E_WRONG_COLLECTION_ID);

        let collection = borrow_global<CountCollection>(@aptos_count);
        table::borrow(&collection.items, collection_id).value
    }

    #[test]
    #[expected_failure(abort_code = E_WRONG_COLLECTION_ID, location = Self)]
    public fun test_get_value_collection_id_out_of_bound() acquires CountCollection {
        get_value(COLLECTION_TYPE_COUNT + 1);
    }

    #[view]
    public fun get_records_length(collection_id: u32): u64 acquires CountCollection {
        assert!(collection_id < COLLECTION_TYPE_COUNT, E_WRONG_COLLECTION_ID);

        let collection = borrow_global<CountCollection>(@aptos_count);

        smart_vector::length(
            &table::borrow(&collection.items, collection_id).records)
    }

    #[test]
    #[expected_failure(abort_code = E_WRONG_COLLECTION_ID, location = Self)]
    public fun test_get_records_length_collection_id_out_of_bound() acquires CountCollection {
        get_records_length(COLLECTION_TYPE_COUNT + 1);
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_get_records_length(framework: &signer, user_1: &signer) acquires CountCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        aptos_count::ft::init_module_for_testing(owner);
        aptos_count::nft::init_module_for_testing(owner);
        aptos_count::fibonacci::init_module_for_testing(owner);

        increment(user_1, COLLECTION_FIBONACCI_ID);
        increment(user_1, COLLECTION_FIBONACCI_ID);
        decrement(user_1, COLLECTION_FIBONACCI_ID);

        assert!(get_records_length(COLLECTION_FIBONACCI_ID) == 3, 4);
    }

    #[view]
    public fun query_all_records(collection_id: u32): vector<CountRecord> acquires CountCollection {
        assert!(collection_id < COLLECTION_TYPE_COUNT, E_WRONG_COLLECTION_ID);

        let collection = borrow_global<CountCollection>(@aptos_count);
        let count = table::borrow(&collection.items, collection_id);
        let all_records = smart_vector::to_vector(&count.records);
        vector::reverse(&mut all_records);
        all_records
    }

    #[test]
    #[expected_failure(abort_code = E_WRONG_COLLECTION_ID, location = Self)]
    public fun test_query_all_records_collection_id_out_of_bound() acquires CountCollection {
        query_all_records(COLLECTION_TYPE_COUNT + 1);
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_query_all_records_in_descending_order(framework: &signer, user_1: &signer) acquires CountCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        aptos_count::ft::init_module_for_testing(owner);
        aptos_count::nft::init_module_for_testing(owner);
        aptos_count::fibonacci::init_module_for_testing(owner);

        timestamp::fast_forward_seconds(1);
        increment(user_1, COLLECTION_FIBONACCI_ID);
        timestamp::fast_forward_seconds(1);
        decrement(user_1, COLLECTION_FIBONACCI_ID);
        timestamp::fast_forward_seconds(1);
        increment(user_1, COLLECTION_FIBONACCI_ID);

        let expected: vector<CountRecord> = vector[
            CountRecord {
                user: @0x123,
                timestamp_us: 3000000,
                action: 1
            },
            CountRecord {
                user: @0x123,
                timestamp_us: 2000000,
                action: 2
            },
            CountRecord {
                user: @0x123,
                timestamp_us: 1000000,
                action: 1
            }
        ];
        let actual = query_all_records(COLLECTION_FIBONACCI_ID);

        assert!(expected == actual, 1);
    }
}