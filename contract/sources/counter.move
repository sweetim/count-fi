module aptos_counter::counter {
    use std::timestamp;
    use std::signer;
    use std::string::String;
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
    use aptos_counter::nft::init_module_for_testing;

    const COUNTER_ACTION_INCREMENT: u8 = 1;
    const COUNTER_ACTION_DECREMENT: u8 = 2;
    const COUNTER_ACTION_RANDOM: u8 = 3;

    const E_NOT_OWNER: u64 = 1;

    struct Counter has key {
        value: u128,
        records: SmartVector<CounterRecord>
    }

    struct CounterRecord has key, store, drop, copy {
        timestamp_us: u64,
        user: address,
        action: u8,
    }

    #[event]
    struct CounterRecordEvent has key, store, drop, copy {
        timestamp_us: u64,
        user: address,
        action: u8,
        value: u128
    }

    struct FibonacciCollection has key, store {
        owners: SmartVector<CollectorOwner>,
        next_index: u128,
    }

    struct CollectorOwner has key, store {
        timestamp_us: u64,
        user: address,
        value: u128,
        index: u128,
    }

    struct CountCollection has key, store {
        items: vector<CountCollectionItem>,
    }

    struct CountCollectionItem has key, store, copy {
        name: String,
        description: String,
        uri: String,
        max_supply: u64,
    }

    fun init_module(owner: &signer) {
        move_to(owner, Counter {
            value: 0,
            records: smart_vector::new()
        });

        move_to(owner, FibonacciCollection {
            next_index: 1,
            owners: smart_vector::new<CollectorOwner>()
        });
    }

    #[test]
    public fun test_init() acquires Counter {
        let owner = account::create_account_for_test(@aptos_counter);
        init_module(&owner);

        assert!(get_value() == 0, 1);
    }

    public entry fun create_collection(owner: &signer) {
        move_to(owner, CountCollection {
            items: vector[]
        })
    }

    public entry fun add_collection(
        owner: &signer,
        name: String,
        description: String,
        uri: String,
        max_supply: u64) acquires CountCollection
    {
        let count_collection = borrow_global_mut<CountCollection>(@aptos_counter);

        vector::push_back(&mut count_collection.items, CountCollectionItem {
            name,
            description,
            uri,
            max_supply
        });
    }

    #[view]
    public fun get_all_collection(): vector<CountCollectionItem> acquires CountCollection {
        let count_collection = borrow_global_mut<CountCollection>(@aptos_counter);
        count_collection.items
    }

    public entry fun increment(user: &signer) acquires Counter, FibonacciCollection {
        perform_action(user, COUNTER_ACTION_INCREMENT);
    }

    inline fun get_random_action(): u8 {
        // randomness::u8_range(
        //     COUNTER_ACTION_INCREMENT,
        //     COUNTER_ACTION_DECREMENT + 1)

        let is_even = timestamp::now_microseconds() % 2 == 0;
        if (is_even) COUNTER_ACTION_INCREMENT else COUNTER_ACTION_DECREMENT
    }

    fun perform_action(user: &signer, action: u8) acquires Counter, FibonacciCollection {
        let current_timestamp_us = timestamp::now_microseconds();
        let user_address = signer::address_of(user);
        let counter_record = CounterRecord {
            action,
            timestamp_us: current_timestamp_us,
            user: user_address
        };

        let action = if (action == COUNTER_ACTION_RANDOM) get_random_action() else action;

        let counter = borrow_global_mut<Counter>(@aptos_counter);
        update_value_from_action(&mut counter.value, action);
        smart_vector::push_back(&mut counter.records, counter_record);

        if (aptos_counter::ft::is_exists()) {
            aptos_counter::ft::mint_to(signer::address_of(user), 1);
        };

        mint_when_value_is_fibonacci(user, counter.value, current_timestamp_us);

        event::emit(CounterRecordEvent {
            action: counter_record.action,
            timestamp_us: counter_record.timestamp_us,
            user: counter_record.user,
            value: counter.value,
        });
    }

    fun mint_when_value_is_fibonacci(user: &signer, value: u128, timestamp_us: u64) acquires FibonacciCollection {
        let user_address = signer::address_of(user);

        let fibonacci_collection = borrow_global_mut<FibonacciCollection>(@aptos_counter);
        let fibonacci_value = get_fibonacci_value(fibonacci_collection.next_index);

        if (value == fibonacci_value) {
            aptos_counter::nft::mint(user_address, value);

            smart_vector::push_back(&mut fibonacci_collection.owners, CollectorOwner {
                value,
                index: fibonacci_collection.next_index,
                timestamp_us,
                user: user_address
            });

            fibonacci_collection.next_index = fibonacci_collection.next_index + 1;
        }
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_mint_when_value_is_fibonacci_true(framework: &signer, user_1: &signer) acquires FibonacciCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_counter);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        init_module_for_testing(owner);

        mint_when_value_is_fibonacci(user_1, 0, 0);

        assert!(
            smart_vector::length(&borrow_global<FibonacciCollection>(@aptos_counter).owners) == 1, 0);
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_mint_when_value_is_fibonacci_false(framework: &signer, user_1: &signer) acquires FibonacciCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_counter);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        init_module_for_testing(owner);

        mint_when_value_is_fibonacci(user_1, 6, 0);

        assert!(
            smart_vector::is_empty(&borrow_global<FibonacciCollection>(@aptos_counter).owners), 0);
    }

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_increment(framework: &signer, user_1: &signer, user_2: &signer) acquires Counter, FibonacciCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_counter);

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

        let event_length = vector::length(&emitted_events<CounterRecordEvent>());
        assert!(event_length == 3, 3);
    }

    public entry fun decrement(user: &signer) acquires Counter, FibonacciCollection {
        perform_action(user, COUNTER_ACTION_DECREMENT);
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
        init_module_for_testing(owner);

        change_value(user_1, 1000);
    }

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_decrement(framework: &signer, user_1: &signer, user_2: &signer) acquires Counter, FibonacciCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_counter);

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

        let event_length = vector::length(&emitted_events<CounterRecordEvent>());
        assert!(event_length == 4, 3);
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_decrement_not_fail_when_zero(framework: &signer, user_1: &signer) acquires Counter, FibonacciCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_counter);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        init_module_for_testing(owner);

        decrement(user_1);
        decrement(user_1);

        assert!(get_value() == 0, 1);
    }

    #[randomness]
    entry fun random(user: &signer) acquires Counter, FibonacciCollection {
        perform_action(user, COUNTER_ACTION_RANDOM);
    }

    fun update_value_from_action(value: &mut u128, action: u8) {
        if (action == COUNTER_ACTION_INCREMENT) {
            *value = *value + 1;
        };

        if (action == COUNTER_ACTION_DECREMENT) {
            if (*value > 0) {
                *value = *value - 1;
            }
        };
    }

    #[test]
    public fun test_update_value_from_action() {
        let value: u128 = 100;

        update_value_from_action(&mut value, COUNTER_ACTION_INCREMENT);
        assert!(value == 101, 1);

        update_value_from_action(&mut value, COUNTER_ACTION_DECREMENT);
        assert!(value == 100, 1);
    }

    #[test(framework = @0x1, user_1 = @0x123, user_2 = @0x321)]
    public fun test_random(framework: &signer, user_1: &signer, user_2: &signer) acquires Counter, FibonacciCollection {
        timestamp::set_time_has_started_for_testing(framework);
        // randomness::initialize_for_testing(framework);
        // randomness::set_seed(x"0000000000000000000000000000000000000000000000000000000000000001");

        let owner = &account::create_account_for_test(@aptos_counter);
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

        let all_emitted_events = &emitted_events<CounterRecordEvent>();

        let expected = vector[
            CounterRecordEvent {
                timestamp_us: 2,
                user: @0x123,
                action: 3,
                value: 1,
            },
            CounterRecordEvent {
                timestamp_us: 3,
                user: @0x321,
                action: 3,
                value: 0,
            },
            CounterRecordEvent {
                timestamp_us: 5,
                user: @0x321,
                action: 3,
                value: 0,
            },
            CounterRecordEvent {
                timestamp_us: 6,
                user: @0x321,
                action: 3,
                value: 1,
            },
            CounterRecordEvent {
                timestamp_us: 8,
                user: @0x123,
                action: 3,
                value: 2,
            }
        ];

        vector::zip_ref(all_emitted_events, &expected, |a, b| assert!(a == b, 1));
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
    public fun test_get_records_length(framework: &signer, user_1: &signer) acquires Counter, FibonacciCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_counter);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        init_module_for_testing(owner);

        increment(user_1);
        increment(user_1);
        decrement(user_1);

        assert!(get_records_length() == 3, 4);
    }

    #[view]
    public fun query_all_records(): vector<CounterRecord> acquires Counter {
        let all_records = smart_vector::to_vector(&borrow_global<Counter>(@aptos_counter).records);
        vector::reverse(&mut all_records);
        all_records
    }

    #[test(framework = @0x1, user_1 = @0x123)]
    public fun test_query_all_records_in_descending_order(framework: &signer, user_1: &signer) acquires Counter, FibonacciCollection {
        timestamp::set_time_has_started_for_testing(framework);

        let owner = &account::create_account_for_test(@aptos_counter);

        account::create_account_for_test(signer::address_of(user_1));

        init_module(owner);
        init_module_for_testing(owner);

        timestamp::fast_forward_seconds(1);
        increment(user_1);
        timestamp::fast_forward_seconds(1);
        decrement(user_1);
        timestamp::fast_forward_seconds(1);
        increment(user_1);

        let expected: vector<CounterRecord> = vector[
            CounterRecord {
                user: @0x123,
                timestamp_us: 3000000,
                action: 1
            },
            CounterRecord {
                user: @0x123,
                timestamp_us: 2000000,
                action: 2
            },
            CounterRecord {
                user: @0x123,
                timestamp_us: 1000000,
                action: 1
            }
        ];
        let actual = query_all_records();

        assert!(expected == actual, 1);
    }

    fun get_fibonacci_value(n: u128): u128 {
        if (n == 0) return 0;
        if (n == 1) return 1;

        let a = 0;
        let b = 1;
        let _c = 0;

        for (i in 2..(n + 1)) {
            _c = a + b;
            a = b;
            b = _c;
        };

        b
    }

    #[test]
    public fun test_get_fibonacci_value() {
        let samples = vector[
            0,
            1,
            1,
            2,
            3,
            5,
            8,
            13,
            21,
        ];

        vector::enumerate_ref(&samples, |i, s| assert!(get_fibonacci_value((i as u128)) == *s, i));
    }

    #[view]
    public fun get_next_fibonacci_value(): u128 acquires FibonacciCollection {
        let fibonacci_collection = borrow_global<FibonacciCollection>(@aptos_counter);
        get_fibonacci_value(fibonacci_collection.next_index)
    }
}