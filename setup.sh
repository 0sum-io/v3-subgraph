#! /bin/bash

# set variables
RPC_URL="https://rpc-pepe-unchained-test-ypyaeq1krb.t.conduit.xyz"
V3_CORE_FACTORY_ADDRESS="0x4eb8aa84c066f9bf210eafe33b30ae49bfafd9a6"
START_BLOCK=961300
NONFUNGIBLE_POSITION_MANAGER_ADDRESS="0xd647b2D80b48e93613Aa6982b85f8909578b4829"
WETH_ADDRESS="0xbe4c021f8fd2be76dbe9da6a000221ac6893aa3d" # lowercased
USD_TOKEN_ADDRESS="0x4f957e108130052849bf81151c6e4c51d5187de1" # lowercased
USDC_WETH_03_POOL="0xbaa50b4a69cd49c2947cc2f94f5f8d7b84676a79" # lowercased

# if darwin, set port to 8000
if [[ "$OSTYPE" == "darwin"* ]]; then
    PORT=8000
else
    PORT=80
fi

# Function to run sed command based on OS
run_sed() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "$1" "$2"
    else
        # Linux and others
        sed -i "$1" "$2"
    fi
}

# Replace text in ./docker-compose.yml with RPC_URL
run_sed "s|<RPC_URL>|$RPC_URL|g" "./docker-compose.yml"

# Replace text in ./docker-compose.yml with PORT
run_sed "s|<PORT>|$PORT|g" "./docker-compose.yml"

# Replace text in ./subgraph.yaml with FACTORY_ADDRESS
run_sed "s|<V3_CORE_FACTORY_ADDRESS>|$V3_CORE_FACTORY_ADDRESS|g" "./subgraph.yaml"

# Replace text in ./subgraph.yaml with START_BLOCK
run_sed "s|<START_BLOCK>|$START_BLOCK|g" "./subgraph.yaml"

# Replace text in ./subgraph.yaml with NONFUNGIBLE_POSITION_MANAGER_ADDRESS
run_sed "s|<NONFUNGIBLE_POSITION_MANAGER_ADDRESS>|$NONFUNGIBLE_POSITION_MANAGER_ADDRESS|g" "./subgraph.yaml"

# Replace text in ./src/utils/constants.ts with V3_CORE_FACTORY_ADDRESS
run_sed "s|<V3_CORE_FACTORY_ADDRESS>|$V3_CORE_FACTORY_ADDRESS|g" "./src/utils/constants.ts"

# Replace text in ./src/utils/constants.ts with WETH_ADDRESS
run_sed "s|<WETH_ADDRESS>|$WETH_ADDRESS|g" "./src/utils/constants.ts"

# Replace text in ./src/utils/constants.ts with USD_TOKEN_ADDRESS
run_sed "s|<USD_TOKEN_ADDRESS>|$USD_TOKEN_ADDRESS|g" "./src/utils/constants.ts"

# Replace text in ./src/utils/constants.ts with USDC_WETH_03_POOL
run_sed "s|<USDC_WETH_03_POOL>|$USDC_WETH_03_POOL|g" "./src/utils/constants.ts"

# install nodejs
if ! command -v node &> /dev/null
then
    echo "nodejs is not installed, installing nodejs"
    sudo apt install nodejs
fi

# install npm
if ! command -v npm &> /dev/null
then
    echo "npm is not installed, installing npm"
    sudo apt install npm
fi

# install yarn 
if ! command -v yarn &> /dev/null
then
    echo "yarn is not installed, installing yarn"
    sudo npm i -g yarn
fi

# install pm2
if ! command -v pm2 &> /dev/null
then
    echo "pm2 is not installed, installing pm2"
    sudo npm i -g pm2
fi

# install docker
if ! command -v docker &> /dev/null
then
    echo "docker is not installed, installing docker"
    curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
fi

# start docker containers
echo "starting docker containers"
if [[ "$OSTYPE" == "darwin"* ]]; then
    docker-compose up -d
else
    sudo docker compose up -d
fi

# pause seconds
echo "pausing..."
sleep 300

# deploy subgraph
echo $"yarn..."
sudo yarn && \
    sudo yarn codegen && \
    sudo yarn build && \
    sudo yarn create-local --access-token ad71fa84f01610bf913efceda5fd7bc3 && \
    sudo yarn deploy-local --access-token ad71fa84f01610bf913efceda5fd7bc3
