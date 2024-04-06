const axios = require('axios'); 
const { writeFileSync } = require('fs');

async function fetchGMXOffchainPriceData(apiUrl) {
    try{
        const res = await axios.get(apiUrl);
        return {data: res['data'].map(obj=>({...obj, minPrice: Number(obj['minPrice']), maxPrice: Number(obj['maxPrice'])}))}
    } catch(e) {
        console.log('error occured while fetching', e);
        return null;
    }
}

function savePriceData(jsonData) {
    const ouput_path = './priceData.json';
    try {
        writeFileSync(ouput_path, JSON.stringify(jsonData), 'utf8');
        console.log('Price data successfully saved to disk');
    } catch (error) {
        console.log('An error has occurred ', error);
    }
}

async function main() {
    const arbiApi = 'https://arbitrum-api.gmxinfra.io/prices/tickers';
    const avaApi = 'https://avalanche-api.gmxinfra.io/prices/tickers';
    const jsonPriceData = await fetchGMXOffchainPriceData(arbiApi);
    if(jsonPriceData) {
        savePriceData(jsonPriceData);
    }
}

main()