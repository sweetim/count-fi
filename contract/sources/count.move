module aptos_count::count {
    use std::timestamp;
    use std::signer;
    use std::vector;

    use aptos_std::smart_vector;
    use aptos_std::smart_vector::SmartVector;
    use aptos_framework::event;

    // use aptos_framework::randomness;

    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_framework::event::emitted_events;
    #[test_only]
    use aptos_count::nft::init_module_for_testing;

    const COUNT_ACTION_INCREMENT: u8 = 1;
    const COUNT_ACTION_DECREMENT: u8 = 2;
    const COUNT_ACTION_RANDOM: u8 = 3;

    const E_NOT_OWNER: u64 = 1;

    const COLLECTION_FIBONACCI_ID: u32 = 0;
    const COLLECTION_PRIME_NUMBER_ID: u32 = 1;
    const COLLECTION_LINEAR_ID: u32 = 2;

    struct CountCollection has key {
        items: vector<Count>
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

    #[event]
    struct CountRecordEvent has key, store, drop, copy {
        timestamp_us: u64,
        user: address,
        action: u8,
        value: u128
    }

    fun init_module(owner: &signer) {
        move_to(owner, Count {
            value: 0,
            records: smart_vector::new()
        });

        move_to(owner, CountCollection {
            items: vector[

            ]
        })
    }

    fun register_collection(id: u32) {

    }

    #[test]
    public fun test_init() acquires Count {
        let owner = account::create_account_for_test(@aptos_count);
        init_module(&owner);

        assert!(get_value() == 0, 1);
    }

    public entry fun increment(user: &signer) acquires Count {
        perform_action(user, COUNT_ACTION_INCREMENT);
    }

    inline fun get_random_action(): u8 {
        // randomness::u8_range(
        //     COUNTER_ACTION_INCREMENT,
        //     COUNTER_ACTION_DECREMENT + 1)

        let is_even = timestamp::now_microseconds() % 2 == 0;
        if (is_even) COUNT_ACTION_INCREMENT else COUNT_ACTION_DECREMENT
    }

    fun perform_action(user: &signer, action: u8) acquires Count {
        let current_timestamp_us = timestamp::now_microseconds();
        let user_address = signer::address_of(user);
        let count_record = CountRecord {
            action,
            timestamp_us: current_timestamp_us,
            user: user_address
        };

        let action = if (action == COUNT_ACTION_RANDOM) get_random_action() else action;

        let count = borrow_global_mut<Count>(@aptos_count);
        update_value_from_action(&mut count.value, action);
        smart_vector::push_back(&mut count.records, count_record);

        if (aptos_count::ft::is_exists()) {
            aptos_count::ft::mint_to(signer::address_of(user), 1);
        };

        // aptos_count::nft::mint(user_address, value);

        event::emit(CountRecordEvent {
            action: count_record.action,
            timestamp_us: count_record.timestamp_us,
            user: count_record.user,
            value: count.value,
        });
    }

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_increment(framework: &signer, user_1: &signer, user_2: &signer) acquires Count {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));
        account::create_account_for_test(signer::address_of(user_2));

        init_module(owner);
        init_module_for_testing(owner);

        increment(user_1);
        assert!(get_value() == 1, 1);

        increment(user_2);
        assert!(get_value() == 2, 2);

        increment(user_1);
        assert!(get_value() == 3, 2);

        let event_length = vector::length(&emitted_events<CountRecordEvent>());
        assert!(event_length == 3, 3);
    }
// 0, 1, 1, 2
    public entry fun decrement(user: &signer) acquires Count {
        perform_action(user, COUNT_ACTION_DECREMENT);
    }

    fun change_value(signer: &signer, value: u128) acquires Count {
        let user_address = signer::address_of(signer);

        assert!(exists<Count>(user_address), E_NOT_OWNER);

        let counter = borrow_global_mut<Count>(user_address);
        counter.value = value;
    }

    #[test(user_1 = @0x123)]
    #[expected_failure]
    public fun test_change_value(user_1: &signer) acquires Count {
        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        init_module_for_testing(owner);

        change_value(user_1, 1000);
    }

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_decrement(framework: &signer, user_1: &signer, user_2: &signer) acquires Count {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));
        account::create_account_for_test(signer::address_of(user_2));

        init_module(owner);
        init_module_for_testing(owner);

        assert!(get_value() == 0, 1);
        change_value(owner, 1000);
        assert!(get_value() == 1000, 1);

        decrement(user_1);
        assert!(get_value() == 999, 1);

        decrement(user_1);
        assert!(get_value() == 998, 1);

        decrement(user_2);
        assert!(get_value() == 997, 1);

        decrement(user_1);
        assert!(get_value() == 996, 1);

        let event_length = vector::length(&emitted_events<CountRecordEvent>());
        assert!(event_length == 4, 3);
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_decrement_not_fail_when_zero(framework: &signer, user_1: &signer) acquires Count {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        init_module_for_testing(owner);

        decrement(user_1);
        decrement(user_1);

        assert!(get_value() == 0, 1);
    }

    #[randomness]
    entry fun random(user: &signer) acquires Count {
        perform_action(user, COUNT_ACTION_RANDOM);
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
    public fun test_random(framework: &signer, user_1: &signer, user_2: &signer) acquires Count {
        timestamp::set_time_has_started_for_testing(framework);
        // randomness::initialize_for_testing(framework);
        // randomness::set_seed(x"0000000000000000000000000000000000000000000000000000000000000001");

        let owner = &account::create_account_for_test(@aptos_count);
        account::create_account_for_test(signer::address_of(user_1));
        account::create_account_for_test(signer::address_of(user_2));

        let actual_value = vector[];

        init_module(owner);
        init_module_for_testing(owner);

        vector::push_back(&mut actual_value, get_value());

        timestamp::update_global_time_for_test(2);
        random(user_1);
        vector::push_back(&mut actual_value, get_value());

        timestamp::update_global_time_for_test(3);
        random(user_2);
        vector::push_back(&mut actual_value, get_value());

        timestamp::update_global_time_for_test(5);
        random(user_2);
        vector::push_back(&mut actual_value, get_value());

        timestamp::update_global_time_for_test(6);
        random(user_2);
        vector::push_back(&mut actual_value, get_value());

        timestamp::update_global_time_for_test(8);
        random(user_1);
        vector::push_back(&mut actual_value, get_value());

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
    public fun get_value(): u128 acquires Count {
        borrow_global<Count>(@aptos_count).value
    }

    #[view]
    public fun get_records_length(): u64 acquires Count {
        smart_vector::length(
            &borrow_global<Count>(@aptos_count).records)
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_get_records_length(framework: &signer, user_1: &signer) acquires Count {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        init_module_for_testing(owner);

        increment(user_1);
        increment(user_1);
        decrement(user_1);

        assert!(get_records_length() == 3, 4);
    }

    #[view]
    public fun query_all_records(): vector<CountRecord> acquires Count {
        let all_records = smart_vector::to_vector(&borrow_global<Count>(@aptos_count).records);
        vector::reverse(&mut all_records);
        all_records
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_query_all_records_in_descending_order(framework: &signer, user_1: &signer) acquires Count {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_count);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        init_module_for_testing(owner);

        timestamp::fast_forward_seconds(1);
        increment(user_1);
        timestamp::fast_forward_seconds(1);
        decrement(user_1);
        timestamp::fast_forward_seconds(1);
        increment(user_1);

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
        let actual = query_all_records();

        assert!(expected == actual, 1);
    }
}