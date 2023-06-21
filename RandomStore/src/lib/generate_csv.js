export function generate_csv(shop) {
    let csvtext = '"name", "description", "price (gp)", "weight (lbs)", "stocked_quantity"\n'
    shop.items.forEach(item => {
        csvtext += `"${item.name}", "${item.description}", "${item.price}", "${item.weight}", "${item.stocked_quantity}"\n`
    })
    return csvtext
}