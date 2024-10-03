rm id.sec
rm id.pub
rm secp.sec
rm secp.pub

./keygen --secret ./id.sec --public ./id.pub
./oyster-keygen --secret ./secp.sec --public ./secp.pub