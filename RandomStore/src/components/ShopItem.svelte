<script>
    export let name = "";
    export let description = "";
    export let price = 0.0;
    export let weight = 0.0;
    export let stocked_quantity = 0;

    import Icon from 'svelte-awesome';
    import infoCircle from 'svelte-awesome/icons/infoCircle';
    import pencil from 'svelte-awesome/icons/pencil';
    import trashO from 'svelte-awesome/icons/trashO';
    import {isViewingShop} from '../stores/SettlementSelectorStore';

    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();

    let editItemDlg;
    let new_price = price;
    let new_weight = weight;
    let new_stocked_quantity = stocked_quantity;

    function deleteItem() {
        dispatch("deleteItem", {
            name: name
        })
    }

    function saveItemChanges() {
        let item = {
            name: name,
            description: description,
            price: new_price,
            weight: new_weight,
            stocked_quantity: new_stocked_quantity
        }
        dispatch("updatedItem", {
            item: item
        })
        editItemDlg.close()
    }
    
    function cancelItemChanges() {
        editItemDlg.close()
    }

    function editItem() {
        editItemDlg.showModal();
    }
</script>

<style>
    .itemWithToolTip {
        position: relative;
    }

    .itemName {
        text-align: left;
    }
    .itemWithToolTip:before {
        content: attr(data-tooltip);
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        left: 100%;
        width: 20rem;
        background-color: black;
        color: white;
        text-align: center;
        padding: 5px;
        border-radius: 6px;
        display: none;
    }

    .itemWithToolTip:hover:before,
    .itemWithToolTip:hover:after {
        display: block;
    }

    .itemWithToolTip:after {
        content: "";
        position: absolute;
        left: 100%;
        margin-left: -20px;
        top: 50%;
        transform: translateY(-50%);
        border: 10px solid #000;
        border-color: transparent black transparent transparent;
        display: none;
    }

    .outOfStock {
        background-color: maroon;
    }

    .editable {
        color: lightblue;
    }
    .delete {
        color: palevioletred
    }
    .editable, .delete {
        border: none;
        border-radius: 0;
        background-color: inherit;
        padding: 0;
    }

    .saveBtn {
        background-color: green;
    }

    .cancelBtn {
        background-color: red;
    }

    .formControl {
        margin-top: 1rem;
    }
</style>

<tr class:outOfStock="{stocked_quantity <= 0}">
    {#if description != ""}
    <td 
        data-tooltip={description}
        class="itemName itemWithToolTip"
    >
        {name}
        <Icon data={infoCircle} />
    </td>
    {:else}
    <td class="itemName">
        {name}
    </td>
    {/if}
    <td class="weight">{weight}</td>  
    <td class="price">
        {price}
    </td>
    <td class="stockedQuantity">
        {stocked_quantity}
    </td>
    {#if !$isViewingShop}
    <td>
        <div>
            <button class="editable" on:click={editItem}><Icon data={pencil} /></button>
            <button class="delete" on:click={deleteItem}><Icon data={trashO} /></button>
        </div>
    </td>
    <dialog bind:this={editItemDlg}>
        <form id="editItemFrm">
            <p>You can override the randomly generated values here</p>
            <label for="weight">Weight (lbs):</label>
            <input id="weight" type="number" bind:value={new_weight}><br>
            <label for="price">Price (gp):</label>
            <input id="price" type="number" bind:value={new_price}><br>
            <label for="stock">Stock:</label>
            <input id="stock" type="number" bind:value={new_stocked_quantity}><br>
            <div class="formControl">
                <button class="saveBtn" on:click|preventDefault={saveItemChanges}>Save</button>
                <button class="cancelBtn" on:click|preventDefault={cancelItemChanges}>Cancel</button>
            </div>
        </form>
    </dialog>
    {/if}
</tr>