module aptos_count::utils {
    #[test_only]
    use std::vector;

    public inline fun iterate_with_index(length: u64, f: |u64|) {
        let i = 0;
        while (i < length) {
            f(i);
            i = i + 1
        }
    }

    #[test]
    public fun test_iterate_with_index() {
        let output = vector[];

        iterate_with_index(10, |i| {
            vector::push_back(&mut output, i);
        });

        assert!(vector::length(&output) == 10, 1);
    }
}
