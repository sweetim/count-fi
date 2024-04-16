## Debug

```
let value_a: u64 = 123;
let value_b: u64 = 321;
debug::print(&string_utils::format2(&b"value_a = ({}), value_b = ({})", value_a, value_b));
```

```
└─▪ aptos move publish --assume-yes
Compiling, may take a little while to download git dependencies...
UPDATING GIT DEPENDENCY https://github.com/aptos-labs/aptos-core.git
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING aptos-counter
package size 6328 bytes
{
  "Error": "Simulation failed with status: Move abort in 0x1::fungible_asset: 0x20013"
}
```
