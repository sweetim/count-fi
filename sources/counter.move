module aptos_counter::counter {
    use std::timestamp;
    use std::signer;
    use aptos_std::smart_vector;
    use aptos_std::smart_vector::SmartVector;
    use aptos_framework::event;

    #[test_only]
    use std::vector;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_framework::event::emitted_events;

    const COUNTER_ACTION_INCREMENT: u8 = 1;
    const COUNTER_ACTION_DECREMENT: u8 = 2;
    const COUNTER_ACTION_RANDOM: u8 = 3;

    const E_NOT_OWNER: u64 = 1;

    struct Counter has key {
        value: u128,
        records: SmartVector<CounterRecord>
    }

    #[event]
    struct CounterRecord has key, store, drop, copy {
        timestamp_us: u64,
        user: address,
        action: u8,
    }

    fun init_module(owner: &signer) {
        move_to(owner, Counter {
            value: 0,
            records: smart_vector::new()
        })
    }

    #[test]
    public fun test_init() acquires Counter {
        let owner = account::create_account_for_test(@aptos_counter);

        init_module(&owner);

        assert!(get_value() == 0, 1);
    }

    public entry fun increment(user: &signer) acquires Counter {
        let counter_record = CounterRecord {
            action: COUNTER_ACTION_INCREMENT,
            timestamp_us: timestamp::now_microseconds(),
            user: signer::address_of(user)
        };

        let counter = borrow_global_mut<Counter>(@aptos_counter);
        counter.value = counter.value + 1;
        smart_vector::push_back(&mut counter.records, counter_record);

        event::emit(counter_record);
    }

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_increment(framework: &signer, user_1: &signer, user_2: &signer) acquires Counter {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_counter);

        account::create_account_for_test(signer::address_of(user_1));
        account::create_account_for_test(signer::address_of(user_2));

        init_module(owner);

        increment(user_1);
        assert!(get_value() == 1, 1);

        increment(user_2);
        assert!(get_value() == 2, 2);

        increment(user_1);
        assert!(get_value() == 3, 2);

        let event_length = vector::length(&emitted_events<CounterRecord>());
        assert!(event_length == 3, 3);
    }

    public entry fun decrement(user: &signer) acquires Counter {
        let counter_record = CounterRecord {
            action: COUNTER_ACTION_INCREMENT,
            timestamp_us: timestamp::now_microseconds(),
            user: signer::address_of(user)
        };

        let counter = borrow_global_mut<Counter>(@aptos_counter);
        if (counter.value > 0) {
            counter.value = counter.value - 1;
        };

        smart_vector::push_back(&mut counter.records, counter_record);

        event::emit(counter_record);
    }

    fun change_value(signer: &signer, value: u128) acquires Counter {
        let user_address = signer::address_of(signer);

        assert!(exists<Counter>(user_address), E_NOT_OWNER);

        let counter = borrow_global_mut<Counter>(user_address);
        counter.value = value;
    }

    #[test(user_1 = @0x123)]
    #[expected_failure]
    public fun test_change_value(user_1: &signer) acquires Counter {
        let owner = &account::create_account_for_test(@aptos_counter);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        change_value(user_1, 1000);
    }

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_decrement(framework: &signer, user_1: &signer, user_2: &signer) acquires Counter {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_counter);

        account::create_account_for_test(signer::address_of(user_1));
        account::create_account_for_test(signer::address_of(user_2));

        init_module(owner);

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

        let event_length = vector::length(&emitted_events<CounterRecord>());
        assert!(event_length == 4, 3);
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_decrement_not_fail_when_zero(framework: &signer, user_1: &signer) acquires Counter {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_counter);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);

        decrement(user_1);
        decrement(user_1);

        assert!(get_value() == 0, 1);
    }

    #[view]
    public fun get_value(): u128 acquires Counter {
        borrow_global<Counter>(@aptos_counter).value
    }

    #[view]
    public fun get_records_length(): u64 acquires Counter {
        smart_vector::length(
            &borrow_global<Counter>(@aptos_counter).records)
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_get_records_length(framework: &signer, user_1: &signer) acquires Counter {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_counter);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);

        increment(user_1);
        increment(user_1);
        decrement(user_1);

        assert!(get_records_length() == 3, 4);
    }

    #[view]
    public fun query_all_records(): vector<CounterRecord> acquires Counter {
        smart_vector::to_vector(&borrow_global<Counter>(@aptos_counter).records)
    }
}