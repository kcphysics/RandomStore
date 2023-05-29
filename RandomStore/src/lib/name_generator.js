import MaleDict from '../data/names-male.json';
import FemaleDict from  '../data/names-female.json';  
import SurNameDict from '../data/names-surnames.json';

let StoreNames = [
    "Country Store",
    "General Store",
    "Bodega",
    "Market",
    "Mart",
    "Trading Post",
    "Outfitters",
    "Emporium",
    "Shop",
    "Shoppe"
]

let MaleNames = MaleDict.data;
let FemaleNames = FemaleDict.data;
let SurNames = SurNameDict.data;

function getRandomItemFromList(list) {
    return list[Math.floor(Math.random() * (list.length - 1))];
}

function generateFullName() {
    if (Math.random() < 0.5) {
        return getRandomItemFromList(MaleNames) + " " + getRandomItemFromList(SurNames);
    } else {
        return getRandomItemFromList(FemaleNames) + " " + getRandomItemFromList(SurNames);
    }
}


export default function generateStoreName() {
    let name = generateFullName();
    let store_name = getRandomItemFromList(StoreNames);
    return name + "'s " +store_name;
}

