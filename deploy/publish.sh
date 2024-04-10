ACCOUNT_ADDRESS="$(cat .aptos/config.yaml | grep account | awk '{split($0, acc, ":"); print acc[2]}')"

aptos move publish \
  --named-addresses aptos_counter="${ACCOUNT_ADDRESS}" \
  --assume-yes

aptos move compile \
  --named-addresses aptos_counter="$(cat .aptos/config.yaml | grep account | awk '{split($0, acc, ":"); print acc[2]}')"