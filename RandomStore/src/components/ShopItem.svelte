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
    .itemName {
        text-align: left;
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
    td > details {
        text-align: left;
    }

    details > summary {
        text-align: left;
    }
</style>

<tr class:outOfStock="{stocked_quantity <= 0}">
    {#if description != ""}
    <td>
        <details>
            <summary>{name}</summary>
            <p>{description}</p>
        </details>
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