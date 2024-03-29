#!/bin/bash

# Go
GO_VERSION=1.19.3

# Node
NODE_REPO=https://github.com/planq-network/planq.git
NODE_VERSION=v1.0.2
NODE_REPO_FOLDER=planq
NODE_DAEMON=planqd
NODE_ID=planq_7070-2
NODE_DENOM=aplanq
NODE_FOLDER=.planqd
NODE_GENESIS_ZIP=false
NODE_GENESIS_FILE=https://snapshots.nodeist.net/planq/genesis.json
NODE_ADDR_BOOK=true
NODE_ADDR_BOOK_FILE=https://snapshots.nodeist.net/planq/addrbook.json

# Service
NODE_SERVICE_NAME=planq

# Validator
VALIDATOR_DETAIL="Cosmos validator, Web3 builder, Staking & Tracking service provider. Staking UI https://explorer.tcnetwork.io/"
VALIDATOR_WEBSITE=https://tcnetwork.io
VALIDATOR_IDENTITY=C149D23D5257C23C

# Snapshot
SNAPSHOT_PATH=https://snap.nodeist.net/planq/planq.tar.lz4

# Upgrade
UPGRADE_PATH=https://github.com/planq-network/planq/releases/download/v1.0.4
UPGRADE_FILE=planq_1.0.4_Linux_arm64.tar.gz


function main {
  echo "                                        NODE INSTALLER                                       ";
  echo "";
  echo "▒███████▒ ▒███▒ ▒███▒    ▒███▒▒██████▒▒███████▒▒██▒         ▒██▒  ▒████▒   ▒█████▒ ▒███▒  ▒██▒";
  echo "   ▒█▒  ▒█▒      ▒█▒ █▒   ▒█▒ ▒█▒        ▒█▒    ▒█▒         ▒█▒ ▒█▒    ▒█▒ ▒█▒  ▒█▒ ▒█▒ ▒█▒   ";
  echo "   ▒█▒ ▒█▒       ▒█▒  █▒  ▒█▒ ▒███▒      ▒█▒     ▒█▒   ▒   ▒█▒ ▒█▒      ▒█▒▒█▒██▒   ▒█▒█▒     ";
  echo "   ▒█▒  ▒█▒      ▒█▒   █▒ ▒█▒ ▒█▒        ▒█▒      ▒█▒ ▒█▒ ▒█▒   ▒█▒    ▒█▒ ▒█▒ ▒█▒  ▒█▒ ▒█▒   ";
  echo "   ▒█▒    ▒███▒ ▒███▒    ▒███▒▒██████▒   ▒█▒       ▒██▒ ▒██▒      ▒████▒   ▒█▒  ▒██▒███▒  ▒██▒";
  echo "";
  echo "Select action by number to do (Example: \"1\"):";
  echo "";
  echo "[1] Install Library Dependencies";
  echo "[2] Install Go";
  echo "[3] Install Node";
  echo "[4] Setup Node";
  echo "[5] Setup Service";
  echo "[6] Create/Import Wallet";
  echo "[7] Create validator";
  echo "[8] Download Snapshot";
  echo "[9] Restart Service";
  echo "";
  echo "[A] Remove Node";
  echo "[B] Upgrade Node";
  echo "[X] Helpful commands";
  echo "";
  read -p "[SELECT] > " input

  case $input in
    "1")
      installDependency
      exit 0
      ;;
    "2")
      installGo
      exit 0
      ;;
    "3")
      installNode
      exit 0
      ;;
    "4")
      initNode
      exit 0
      ;;
    "5")
      installService
      exit 0
      ;;
    "6")
      createImportWallet
      exit 0
      ;;
    "7")
      createValidator
      exit 0
      ;;
    "8")
      downloadSnapshot
      exit 0
      ;;
    "9")
      restartService
      exit 0
      ;;
    "A")
      removeNode
      exit 0
      ;;
    "B")
      upgradeNode
      exit 0
      ;;
    "X")
      helpfullCommand
      exit 0
      ;;
    *)
      echo "Invalid input - $input\n"
      ;;
    esac
}

function installDependency() {
  echo -e "\e[1m\e[32mInstalling Dependency... \e[0m" && sleep 1

  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt install curl chrony wget make gcc git jq build-essential snapd lz4 unzip -y
}

function installGo() {
  echo -e "\e[1m\e[32mInstalling Go... \e[0m" && sleep 1

  if [ ! -d "/usr/local/go" ]; then
    cd $HOME
    wget "https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go$GO_VERSION.linux-amd64.tar.gz"
    sudo rm "go$GO_VERSION.linux-amd64.tar.gz"

    echo -e "\e[1m\e[32mInstallation Go done. \e[0m" && sleep 1
  else
    echo -e "\e[1m\e[32mGo already installed with version: \e[0m" && sleep 1
  fi

  PATH_INCLUDES_GO=$(grep "$HOME/go/bin" $HOME/.profile)
  if [ -z "$PATH_INCLUDES_GO" ]; then
    echo "export GOROOT=/usr/local/go" >> $HOME/.profile
    echo "export GOPATH=$HOME/go" >> $HOME/.profile
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.profile
  fi

  source $HOME/.profile
  go version

  echo -e "If go version return nothing, try to apply again: source $HOME/.profile" && sleep 1  
}

function installNode() {
  # remove previous tools
  echo -e "\e[1m\e[32mRemoving previous installed tools... \e[0m" && sleep 1
  if [ -f "/usr/local/bin/$NODE_DAEMON" ]; then
    sudo rm -rf usr/local/bin/$NODE_DAEMON
  fi

  # Install binary
  echo -e "\e[1m\e[32mInstalling Node... \e[0m" && sleep 1
  cd $HOME

  git clone $NODE_REPO
  cd $NODE_REPO_FOLDER 
  git checkout $NODE_VERSION
  make install

  echo -e "\e[1m\e[32mInstalling Node finished. \e[0m" && sleep 1
}

function initNode() {
  echo -e "\e[1m\e[32mInitialize Node... \e[0m" && sleep 1

  # Set Vars
  if [ ! $NODE_NAME ]; then
    read -p "[ENTER YOUR NODE NAME] > " NODE_NAME
    read -p "[ENTER YOUR NODE PORT] > " NODE_PORT
  fi

  echo ""
  echo -e "YOUR NODE NAME : \e[1m\e[31m$NODE_NAME\e[0m"
  echo -e "NODE CHAIN ID  : \e[1m\e[31m$NODE_ID\e[0m"
  echo -e "NODE PORT      : \e[1m\e[31m${NODE_PORT}657\e[0m"
  echo ""

  PROFILE_INCLUDED=$(grep "NODE_NAME" $HOME/.profile)
  if [ -z "$PROFILE_INCLUDED" ]; then
    echo "export NODE_NAME=\"${NODE_NAME}\"" >> $HOME/.profile
    echo "export NODE_PORT=${NODE_PORT}" >> $HOME/.profile
    source ~/.profile
  fi
  
  # Initialize Node
  if [ ! -d "$HOME/$NODE_FOLDER" ]; then
    $NODE_DAEMON init "$NODE_NAME" --chain-id=$NODE_ID

    # keyring
    #$NODE_DAEMON config keyring-backend test
  fi

  # Download Genesis
  cd $HOME
  echo -e "\e[1m\e[32mDownloading Genesis File... \e[0m" && sleep 1

  if $NODE_GENESIS_ZIP; then
    echo "Downloading zip file..."
    curl -s $NODE_GENESIS_FILE -o $HOME/genesis.json.gz
    gunzip $HOME/genesis.json.gz
    sudo mv $HOME/genesis.json $HOME/$NODE_FOLDER/config
  else
    echo "Downloading plain genesis file..."
    #curl -s $NODE_GENESIS_FILE > $HOME/$NODE_FOLDER/config/genesis.json
    wget -O genesis.json $NODE_GENESIS_FILE --inet4-only
    mv genesis.json $HOME/$NODE_FOLDER/config
  fi


  # Download addrbook
  if $NODE_ADDR_BOOK; then
    #wget -O $HOME/$NODE_FOLDER/config/addrbook.json $NODE_ADDR_BOOK_FILE
    wget -O addrbook.json $NODE_ADDR_BOOK_FILE --inet4-only
    mv addrbook.json $HOME/$NODE_FOLDER/config
  fi

  echo "Setting configuration..."
  CONFIG_PATH="$HOME/$NODE_FOLDER/config/config.toml"
  APP_PATH="$HOME/$NODE_FOLDER/config/app.toml"

  # seed
  echo "Setting Seed..."
  SEEDS=""
  sed -i.bak "s/^seeds *=.*/seeds = \"$SEEDS\"/;" $CONFIG_PATH

  # peer
  PEERS="56e4d0fb7b7e95e9d8f1e19ef106ef98767c4a33@65.109.69.240:34656,60d86f728656b170956f826f54139b8bd6d16205@173.249.9.48:26656,187b78663e51365f9f8790fe55eaefe0d6bfc9a1@188.166.13.20:26656,988473a2c5ca422e1e02b662cf6c4f5e0f7730af@206.189.150.25:14656,bcfe65dde6255a18710261744156b8ef9eb60a23@161.35.136.213:33656,5c6af12d44dca1f2aa108596335a79675214657e@213.136.68.150:14656,7411e1c10069b77a0ffa28fd7020be434338eecb@23.88.2.221:31656,fe1d202d7ee8a65172e3603724fb287139551288@164.90.128.166:33656,e8819a01fb133432b5875a74e60645c385b22a2d@23.88.99.40:60656,c66c7b403ad5569fa41997923954eae2cd8cb03a@143.244.150.50:60656,36903114ce03783c75ed476eb36d379925b90ab3@143.198.189.41:60656,820c4e2be4388f5a5e7031e4c363149daf3f63b7@144.126.155.29:33656,a11c39532ca0d2501ee68688325951dfc13119d4@185.217.127.138:14656,09bf31b7f0d4c40e39050799478430e289a83bdc@93.186.200.215:60656,ef7b69b1975fa845e8e8ca235e6de5090151eac8@137.184.84.96:60656,8e1202c7a7df0fcef04a2cb348206a0efacceb26@165.22.223.88:26656,4dd87c7cb654666117e9926ea0a5ba41e1c56ea5@146.190.90.194:33656,e7a2929fa8273d0aa0a83b2a25ad4fbdf4471558@212.227.73.190:29656,941d9b6adfa0e61bd3c5e11d397a9ed5f8a7d795@146.190.172.173:33656,67109f02215f3fba727a6acee3547b14728a0931@45.134.226.15:60656,c6093258eaf65c1c05d16494f2cb204b7eab3404@128.199.144.209:60656,b3211b205d2b2b08badffe806cc61a76e827a27f@178.128.127.160:33656,ff000ce1d4a45a28fe5d45f55a9db539d1c7d367@134.209.25.226:33656,21bcfcec520c2510f91744af0e8c6cad9faf0056@143.198.131.136:33656,ebe63891bf409e334e1a6cdb5c307999a48afa42@95.216.7.171:26656,a034ebeabe1e642ffe402c4ee139fa6700307511@143.198.49.161:33656,744a9db685c99ee7195a546ff1f27afd507babf4@87.106.112.86:33656,3fd002790baf7913921903b8c0b27f217088144f@185.190.140.93:14656,1eb933fb4aad816e8aef62984c670ad3ee9f55fc@147.182.238.59:33656,14dc39824338b18cf6fa157e518cb74941c38866@45.84.138.246:14656,36243de872ba916aa75c7ffac0f39098b5535fea@85.214.33.202:33656,dd2f0ceaa0b21491ecae17413b242d69916550ae@135.125.247.70:26656,2e25e5ae74438afd464b0d9bec9aceff2c684b5f@159.223.93.59:60656,8020f58e736388b30c41e50c31328375175bf16d@5.189.138.167:33656,980edf1f75f7a8e4398bdcd274241c965df4afce@24.199.123.198:26656,c1cb0804704577847f39d77dbb46bb14346ef62f@164.92.84.106:33656,7417965190006b3e1c25513f7270aa4bd09468be@194.135.89.125:33656,11a6b1905a034e49746c9405a4440ff46dcea6b3@194.163.143.132:33656,8784492ab572d656b4614e528d8720ec4f04c5c2@139.144.52.110:26656,6baa7117f17f8e6ca01fa2c247318a498b0025c3@38.242.155.79:14656,9647d858f600df5c5783372af261c27f6e9fbf01@146.190.62.103:60656,72d9fc05958d509e7062b1853eba9252155a39bd@159.223.78.153:26656,0cea8cdfe4963adb20b0a034e3d3af42a831a830@95.216.114.212:14656,01dd32aaf0af44a198a7a7ffec064649289da3db@149.102.153.49:656,3b17e48fc64523b67c64e73722aa3b3b927c1ec0@138.197.15.201:14656,8fed9c4c20c3628baaea79a5d4f490005aae8543@143.198.99.102:60656,bef7b04b3f7d62f0ffac5ac118b57084d0a3e168@65.109.111.204:27656,0d371786866b7d4985dd6ce91e247810fe9a2652@185.219.142.121:26656,8065cbcffabdd187806aa9eca91cc028646f54ae@45.130.104.221:33656,6b8ee48f2dedccaa6e0f424fbc0275e116aeef6b@34.154.254.122:26656,1a1785bf66f47a2eff058fe770be6b6b1b694400@38.242.148.96:27656,ea36cef022964f929707705a7d5f87950908cdfe@78.107.234.44:26656,c86c1f4a57cd366b10d80ee472438ae9a9a717d7@159.223.152.181:60656,d5d78fcff08500f2963c37d6d641fe9769828432@38.242.147.198:14656,c3dda646a98f79d896a719af710019c4d1d176ab@65.108.9.164:44656,0c2ed4f17609b636ec93a55278d454670de8eaee@65.108.250.241:60756,e2af00705d2435169db71d56e53ba6c59cddff46@185.250.36.184:55656,53ce9c11ebb41c7204e18b4d47555c7acf0e289f@159.69.204.44:26656,9664e782e385774525451f534bd682cc0367e5f9@185.207.250.233:46656,9e3c33ba3cd5bc55a16b8b92a5db9ab5622c1260@146.190.39.185:33656,8605c013e6f03bc39aabbf03e8da050cf43cd595@34.102.100.227:33656,1c61c7036b781b3f3aff9add0351e6b8f7dae5ba@146.190.58.230:60656,af47bda0a78aa7d9d3bd5b18515c9ea5715d9b29@143.198.154.29:60656,938f1720a3ec8a168553a9d5b3be5eee1d078108@162.55.245.219:14656,977bb9fb5572cedc61a78636bcb1448414fdae2c@134.209.79.182:60656,f9d456e6b78f39c849cbab53899e181f4964264d@159.223.201.227:26656,9167d948ddfb7ac746c6e111aaf8110268be9859@45.94.209.3:60656,84c257c748f9648a877c00e1786d545e666f2ad0@164.92.64.114:26656,06922d6265a5f20789cfb182641e28d0b243ea45@34.173.129.126:60656,3ae3ca86dd1ca31c3dee9228d8d8b828c5648556@146.190.55.151:33656,23bb88d39d982938cc6b0f97031a1c63434651f6@87.106.114.73:14656,b2c63d0b44a468c94ebc3d14dc7eb776f37d0f85@188.166.224.158:14656,ca078c3c98a68629a6f3ae31f9620d658f3471f4@154.26.138.219:60656,adb0f56a70f4c481521776152a8dc34f0b3eabe8@137.184.189.27:60656,cbde9f25c2783ed497a31ddad81ad011e7139789@65.108.8.247:20356,b777e578b3664661de1e7ee1b063e2606bd6a6fc@142.93.207.43:33656,c67c62a8f3017b89b7ce8b537786ea77422bdfe4@139.59.116.251:60656,938cc128b0dc5e012c502d38ddc03b671fd63e8f@57.128.34.148:26656,d107502b5314ad43fd52f2356e6bdbeb0bd419d9@45.79.208.138:11656,cf425951e38319ab529f83e64b3197cc65f20306@34.84.112.19:60656,37797500a67bde47b717f1d693bbd895e1cf3403@169.0.73.24:26656,e3ac425868500788f4f230ef101d52a0ea339672@192.99.44.79:20356,ff8c31dd8f8e384cf03b3cc342d9a1d448cd1cc4@194.195.90.16:60656,92253794ad89c93d7bf5417b052656208fed4f93@178.128.85.30:14656,e3c5032f859ee0955bc3ad944955e4283796e0d2@217.76.56.245:33656,4d44b699af2c4b0a6b8dfdf266a8dc17765113db@135.181.0.87:13656,141ec0ddef8685b3ec3870d929193024539abe93@194.163.133.221:60656,233a54cb3b1f322083fa9f4e49eec1ac7905078f@34.125.214.216:33656,12420ad898096fe8500bc4912356d4cc374319b5@147.182.224.179:60656,97c53c39bb622da97a3aa4ab8cc6db32e67d6e8f@146.59.110.50:26656,b76abe67188be594e17d6e25c7231b027c8bd324@34.175.12.246:26656,96ea4abdc147d955b0fcb0a962f4db4c2840c04e@159.223.46.214:33656,51188b35f4eb31f6e7449598352c855c8c71ad23@95.217.109.222:17656,f6616adebc271c4780885443431644c73c99d789@54.37.78.240:26656,a7bcb1429665bb47fc1eb88bed7383910803997d@216.250.122.1:60656,1e305437e9a3bbd68a304022ac397aba4cbd4a62@109.123.240.42:14656,d807d55d32a6d8de6f931fcb24d55004488a97f7@104.152.109.134:33656,3866405810bbfd1c159ebb9280f7e54a39a6434f@185.252.235.83:30656,ddd1e324d4a2863d26a32214f5e0aa3612cd747b@162.55.194.205:14656,f9076f84077e55bd55620419b3494ef624d1eff3@15.235.45.219:26656,652f2148e92827f65dfa1e9c08274e3cd3148d54@198.71.61.239:60656,7177cdfc5ca7abb26dc55d397fce64208e103eed@65.108.194.87:23656,c34b966750169b0a4817b5af8508f0e057889a02@51.89.118.48:18656,b88fda6d20faf5419ec1f921ee561442e3a813fa@144.126.222.159:60656,6ca7ca0a55a385e24985d5cd477d5dcf398d723d@206.189.35.19:14656,85a309b27c9ee6445e1711e6a7305338b819565d@18.224.64.227:26656,72af1bb808605551a34f362ed02b0d86f1d9bd2f@68.183.138.50:60656,3eb12284b7fb707490b8adfda6fa7d94e2fa5cd9@94.130.54.253:16603,603a1c6123c11eed2434be0d50b1eb520ee30d18@38.242.133.69:14656,2ce64749269f6bb15acaaa4abc0712f5e91ed588@82.208.20.91:27656,a3b8955aa523285d0aed51c7bfaf19eb20264ef5@37.120.171.213:10656,ad59944b6867040f96172ec44065127a660fe3cb@139.59.118.165:60656,c087d7622a297574facb4845281d3b2fed02315f@185.188.249.173:60656,23dfcfeb7ee1d0ec7a4ed2753ceba2f3a81a5aac@85.239.234.218:14656,ec11a8bfc5dd888feb4fbe213e8ff59b4ada83bf@216.250.122.2:60656,bfadf6e85a9857951fe1951a55c6ee0a4364d59e@178.128.223.22:60656,266d72c493261be8f7e631af946e941141178738@139.59.111.252:14656,3178e00bb9e6d02ffbe11c9e55e5e4911317f66a@178.128.101.31:33656,301658a48009d3377ac80ea80e5cf6add9ef52e6@65.109.88.155:17656,8a8d6e8168b744e9f3067f682b642eeeb0d963c9@185.215.166.244:33656"
  sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $CONFIG_PATH

  # log
  echo "Setting Log..."
  sed -i -e "s/^log_level *=.*/log_level = \"warn\"/" $CONFIG_PATH

  # indexer
  echo "Setting Indexer..."
  sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $CONFIG_PATH

  # prometheus
  echo "Setting Prometheus..."
  sed -i -e "s/prometheus = false/prometheus = false/" $CONFIG_PATH

  # inbound/outbound
  sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $CONFIG_PATH
  sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $CONFIG_PATH

  # port
  echo "Setting Port..."
  sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NODE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NODE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NODE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NODE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NODE_PORT}660\"%" $CONFIG_PATH
  sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NODE_PORT}317\"%; s%^address = \":8080\"%address = \":${NODE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NODE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NODE_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${NODE_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${NODE_PORT}546\"%" $APP_PATH

  # gas
  echo "Setting Minimum Gas..."
  sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025$NODE_DENOM\"/" $APP_PATH

  # pruning
  echo "Setting Prunching..."
  pruning="custom"
  pruning_keep_recent="100"
  pruning_keep_every="0"
  pruning_interval="10"
  sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $APP_PATH
  sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $APP_PATH
  sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $APP_PATH
  sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $APP_PATH

  # snapshot-interval
  echo "Setting Snapshot..."
  sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = 0/" $APP_PATH

  echo -e "\e[1m\e[32mInit Node successful. \e[0m"
}

function installService() {
  echo -e "\e[1m\e[32mInstalling service... \e[0m" && sleep 1

  if [ ! -f "/etc/systemd/system/$NODE_SERVICE_NAME.service" ]; then

sudo tee <<EOF >/dev/null /etc/systemd/system/$NODE_SERVICE_NAME.service
  [Unit]
  Description=$NODE_SERVICE_NAME Node
  After=network.target

  [Service]
  User=$USER
  Type=simple
  ExecStart=$(which $NODE_DAEMON) start
  Restart=on-failure
  RestartSec=3
  LimitNOFILE=65535

  [Install]
  WantedBy=multi-user.target
EOF

    # Enable systemd service
    echo -e "\e[1m\e[32mEnable service... \e[0m" && sleep 1

    sudo systemctl daemon-reload
    sudo systemctl enable $NODE_SERVICE_NAME.service

    echo -e "\e[1m\e[32mInstallation service finished. \e[0m" && sleep 1
  else
    echo -e "\e[1m\e[32mService already exist... \e[0m" && sleep 1
  fi
}

function createImportWallet() {
  echo "Do you want to create or import wallet?"
  echo "[1] Create new wallet"
  echo "[2] Import wallet"
  echo "";

  read -p " > " ACTION_WALLET
  read -p "[ENTER YOUR AlIAS WALLET NAME] > " NODE_WALLET

  case $ACTION_WALLET in
    "1")
      $NODE_DAEMON keys add $NODE_WALLET
      ;;

    "2")
      $NODE_DAEMON keys add $NODE_WALLET --recover
      ;;

    *)
      echo "Invalid input - $input"
      return 1
      ;;
  esac

  echo "export NODE_WALLET=${NODE_WALLET}" >> $HOME/.profile
  source $HOME/.profile

  echo -e "\e[1m\e[32mCreate/Import wallet successful. \e[0m" && sleep 1
}

function createValidator() {
  if [ ! $NODE_WALLET ]; then
    echo -e "\e[1m\e[32mPlease create/import wallet before create validator! \e[0m" && sleep 1
    return 1
  fi

  if [ ! $NODE_NAME ]; then
    echo -e "\e[1m\e[32mPlease setup node before create validator! \e[0m" && sleep 1
    return 1
  fi

  echo ""
  echo "Please define your information, leave empty to use default (TC Network)"
  read -p "[YOUR WEBSITE] > " YOUR_WEBSITE
  read -p "[YOUR IDENTITY] > " YOUR_IDENTITY
  read -p "[YOUR DESCRIPTION] > " YOUR_DETAIL 

  if [[ $YOUR_WEBSITE = "" ]]; then
    YOUR_WEBSITE=$VALIDATOR_WEBSITE
  fi 
  if [[ $YOUR_IDENTITY = "" ]]; then
    YOUR_IDENTITY=$VALIDATOR_IDENTITY
  fi 
  if [[ $YOUR_DETAIL = "" ]]; then
    YOUR_DETAIL=$VALIDATOR_DETAIL
  fi 

  echo -e "YOUR WEBSITE     : \e[1m\e[31m$YOUR_WEBSITE\e[0m"
  echo -e "NODE IDENTITY    : \e[1m\e[31m$YOUR_IDENTITY\e[0m"
  echo -e "NODE DESCRIPTION : \e[1m\e[31m$YOUR_DETAIL\e[0m"
  echo ""
  echo -e "\e[1m\e[32mCreating Valdiator Tx with wallet $NODE_WALLET... \e[0m" && sleep 1

  $NODE_DAEMON tx staking create-validator \
  --amount=1000000$NODE_DENOM \
  --pubkey=$($NODE_DAEMON tendermint show-validator) \
  --from="$NODE_WALLET" \
  --chain-id=$NODE_ID \
  --moniker="$NODE_NAME" \
  --commission-max-change-rate=0.01 \
  --commission-max-rate=0.10 \
  --commission-rate=0.05 \
  --details="$YOUR_DETAIL" \
  --website="$YOUR_WEBSITE" \
  --identity "$YOUR_IDENTITY" \
  --min-self-delegation="1000000" \
  --gas-prices="30000000000$NODE_DENOM" \
  --gas="1000000" \
  --node=tcp://127.0.0.1:${NODE_PORT}657

  echo -e "\e[1m\e[32mCreate Valdiator successful. \e[0m" && sleep 1
}

function downloadSnapshot() {
  if [[ $SNAPSHOT_PATH == "" ]]; then
    echo "Not existing Snapshot path to process."
    return 1
  fi

  echo -e "\e[1m\e[32mDownloading snapshot... \e[0m" && sleep 1

  $NODE_DAEMON tendermint unsafe-reset-all --home $HOME/$NODE_FOLDER --keep-addr-book
  curl -L $SNAPSHOT_PATH | lz4 -dc - | tar -xf - -C $HOME/$NODE_FOLDER --strip-components 2

  echo -e "\e[1m\e[32mDownload snapshot finished. \e[0m" && sleep 1
}

function restartService() {
  echo -e "\e[1m\e[32mRestarting service... \e[0m" && sleep 1

  sudo systemctl restart $NODE_SERVICE_NAME
  sudo systemctl status $NODE_SERVICE_NAME

  echo -e "\e[1m\e[32mStart service done... \e[0m" && sleep 1
  echo -e "\e[1m\e[32mRun command to check log: sudo journalctl -u $NODE_SERVICE_NAME -f -o cat \e[0m" && sleep 1
}

function removeNode() {
  echo -e "\e[1m\e[32mRemoving Node... \e[0m" && sleep 1
 
  if [ -f "/etc/systemd/system/$NODE_SERVICE_NAME.service" ]; then
    echo "Stop and remove service..."
    sudo systemctl stop $NODE_SERVICE_NAME
    sudo systemctl disable $NODE_SERVICE_NAME
    sudo rm /etc/systemd/system/$NODE_SERVICE_NAME.service
  fi

  echo "Removing Daemon..."
  if [ -f "$(which $NODE_DAEMON)" ]; then
    sudo rm -rf $(which $NODE_DAEMON)
  fi

  echo "Removing Node folder..."
  if [ -d "$HOME/$NODE_FOLDER" ]; then
    sudo rm -rf $HOME/$NODE_FOLDER
  fi
  
  echo "Removing Repo folder..."
  if [ -d "$HOME/$NODE_REPO_FOLDER" ]; then
    sudo rm -rf $HOME/$NODE_REPO_FOLDER
  fi

  echo "Removing environment variables..."
  unset NODE_NAME
  unset NODE_PORT
  
  echo -e "\e[1m\e[32mRemove Node successful. \e[0m" && sleep 1
}

function upgradeNode() {
  if [[ $UPGRADE_PATH == "" ]]; then
    echo "Not existing download path to process."
    return 1
  fi

  if [[ $UPGRADE_FILE == "" ]]; then
    echo "Not existing download file to process."
    return 1
  fi

  echo -e "\e[1m\e[32mDownloading snapshot... \e[0m" && sleep 1

  sudo mkdir $HOME/upgrade && cd $HOME/upgrade
  sudo wget $UPGRADE_PATH/$UPGRADE_FILE
  sudo tar xfv $UPGRADE_FILE

  echo -e "\e[1m\e[32mShutting down node... \e[0m" && sleep 1
  sudo systemctl stop $NODE_SERVICE_NAME 
  sudo systemctl status $NODE_SERVICE_NAME

  echo -e "\e[1m\e[32mUpgrading node... \e[0m" && sleep 1
  sudo rm $HOME/go/bin/$NODE_DAEMON
  sudo mv $HOME/upgrade/bin/$NODE_DAEMON $HOME/go/bin
  sudo rm -rf $HOME/upgrade

  echo -e "\e[1m\e[32mRestarting node... \e[0m" && sleep 1
  sudo systemctl restart $NODE_SERVICE_NAME

  echo "\e[1m\e[32mUpgrade node finished. \e[0m"
  echo "\e[1m\e[32mRun command to check log: sudo journalctl -u $NODE_SERVICE_NAME -f -o cat \e[0m"
}

function helpfullCommand() {
  VALIDATOR_ADDRESS=$($NODE_DAEMON keys show $NODE_WALLET --bech val -a)

  echo "Check log:"
  echo "sudo journalctl -u $NODE_SERVICE_NAME -f -o cat"
  echo ""
  echo "Check sync status:"
  echo "curl -s localhost:${NODE_PORT}657/status | jq -r .result.sync_info"
  echo ""
  echo "Unjail validator:"
  echo "$NODE_DAEMON tx slashing unjail --from $NODE_WALLET --chain-id $NODE_ID --node tcp://127.0.0.1:${NODE_PORT}657 --fees 10000$NODE_DENOM -y"
  echo ""
  echo "Withdraw reward and commission:"
  echo "$NODE_DAEMON tx distribution withdraw-rewards $VALIDATOR_ADDRESS --from $NODE_WALLET --chain-id $NODE_ID --node tcp://127.0.0.1:${NODE_PORT}657 --commission -y"
  echo ""
  echo "Delegate:"
  echo "$NODE_DAEMON tx staking delegate $VALIDATOR_ADDRESS 1000000$NODE_DENOM --from $NODE_WALLET --chain-id $NODE_ID --node tcp://127.0.0.1:${NODE_PORT}657 -y"
  echo ""
  echo "Vote proposal X"
  echo "$NODE_DAEMON tx gov vote X yes|no|abstain|nowithveto --from $NODE_WALLET --chain-id $NODE_ID --node tcp://127.0.0.1:${NODE_PORT}657 -y"
  echo ""
}


function checksum() {
  NODE_FOLDER=.ollo
  NODE_GENESIS_CHECKSUM=4852e73a212318cabaa6bf264e18e8aeeb42ee1e428addc0855341fad5dc7dae

  if [[ $(sha256sum "$HOME/$NODE_FOLDER/config/genesis.json" | cut -f 1 -d' ') == "$NODE_GENESIS_CHECKSUM" ]]; then
    echo "Genesis checksum is match"
  else
    echo "Genesis checksum is not match"
    return 1
  fi
}

function checkProfile() {
  PROFILE_INCLUDED=$(grep "NODE_NAME" $HOME/.profile)
  if [ -z "$PROFILE_INCLUDED" ]; then
    echo "add to profile"
    echo "export NODE_NAME=${NODE_NAME}" >> $HOME/.profile
    echo "export NODE_PORT=${NODE_PORT}" >> $HOME/.profile
    source $HOME/.profile
  else
    echo "already added to bash profile"
  fi
}

main

# Test
# checksum
# checkProfile

# Run:
# On Mac: sh node-tool.sh
# On Ubuntu: sudo chmod +x node.sh && ./node.sh
