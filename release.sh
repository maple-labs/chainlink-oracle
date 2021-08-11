#!/usr/bin/env bash
set -e

while getopts v: flag
do
    case "${flag}" in
        v) version=${OPTARG};;
    esac
done

echo $version

./build.sh -c ./config/prod.json

rm -rf ./package
mkdir -p package

echo "{
  \"name\": \"@maplelabs/chainlink-oracle\",
  \"version\": \"${version}\",
  \"description\": \"Chainlink Oracle Artifacts and ABIs\",
  \"author\": \"Maple Labs\",
  \"license\": \"AGPLv3\",
  \"repository\": {
    \"type\": \"git\",
    \"url\": \"https://github.com/maple-labs/chainlink-oracle.git\"
  },
  \"bugs\": {
    \"url\": \"https://github.com/maple-labs/chainlink-oracle/issues\"
  },
  \"homepage\": \"https://github.com/maple-labs/chainlink-oracle\"
}" > package/package.json

mkdir -p package/artifacts
mkdir -p package/abis

cat ./out/dapp.sol.json | jq '.contracts | ."contracts/ChainlinkOracle.sol" | .ChainlinkOracle' > package/artifacts/ChainlinkOracle.json
cat ./out/dapp.sol.json | jq '.contracts | ."contracts/ChainlinkOracle.sol" | .ChainlinkOracle | .abi' > package/abis/ChainlinkOracle.json

npm publish ./package --access public

rm -rf ./package
