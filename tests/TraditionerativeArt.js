const TraditionerativeArt = artifacts.require("TraditionerativeArt");
const tokens = ["1", "2"];
contract("TraditionerativeArt", (accounts) => {
    let [alice, bob] = accounts;
    it("should be able to mint a new token", async () => {
        const contractInstance = await TraditionerativeArt.new();
    })
})