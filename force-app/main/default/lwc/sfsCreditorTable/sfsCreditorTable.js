import { LightningElement, wire } from 'lwc';
import getJson from '@salesforce/apex/SfsDataRetrieve.getJson';

const actions = [];

const columns = [
    { label: 'Creditor', fieldName: 'creditorName', editable: true },
    { label: 'First Name', fieldName: 'firstName', editable: true },
    { label: 'Last Name', fieldName: 'lastName', editable: true },
    { label: 'Min Pay %', fieldName: 'minPaymentPercentage', type: 'percent', editable: true }, //table/formatted-number formatting is off by a factor of 100 (100 is displaying as 10,000%)
    { label: 'Balance', fieldName: 'balance', type: 'currency', editable: true },

];

export default class SfsCreditorTable extends LightningElement {
    data = [];
    columns = columns;
    record = {};
    draftValues = [];
    selectedTotal = 0;
    totalRowCount = 0;
    checkedRowCount = 0;

    @wire(getJson)
    fetchedData({error, data}) {
        if (error) {
            console.error(error);
        }
        if (data) {
            this.data = this.fixPercentFormatting(JSON.parse(data));
            this.totalRowCount = Object.keys(this.data).length;
        }
    }

    fixPercentFormatting(data) {
        data.forEach((row) => {
            if (row.minPaymentPercentage > 1)  row.minPaymentPercentage = row.minPaymentPercentage * .01;
        });
        console.log(data);
        return data;
    }

    handleClick(event){
        const buttonLabel = event.target.label;
        if (buttonLabel === 'Add Debt') this.addRow();
        if (buttonLabel === 'Remove Debt') this.deleteRows();
    }

    addRow() {
        let data = new Array();
        data = JSON.parse(JSON.stringify(this.data));

        let newRow = new Object();

        newRow.id = Object.keys(data).length > 0 ? Object.values(data)[Object.keys(data).length-1].id + 1 : 1;
        newRow.creditorName = '';
        newRow.firstName = '';
        newRow.lastName = '';
        newRow.minPaymentPercentage = new Number();
        newRow.balance = new Number();
        data.push(newRow);

        this.data = data;
        this.totalRowCount = Object.keys(data).length;
    }

    deleteRows() {
        let data = JSON.parse(JSON.stringify(this.data));

        let newData = [];
        let i = 1;

        data.forEach((row) => {
            if (!row.checked) {            
                newData.push(row);
                i++;
            }
        });
        this.data = newData;
        this.totalRowCount = Object.keys(newData).length;
    }


    handleRowAction(event) {
        let data = JSON.parse(JSON.stringify(this.data));
        let selectedRowIds = [];
        let total = 0;
        let checkedTotal = 0;

        event.detail.selectedRows.forEach((row) => {
            selectedRowIds.push(row.id);
        });
        
        data.forEach((row) => {
            //row.checked = selectedRowIds.includes(row.id) ? true : false;          
            if (selectedRowIds.includes(row.id)) {
                row.checked = true;
                total += Number(row.balance);
                checkedTotal += 1;
            } else {
                row.checked = false;
            }

        });

        this.data = data;
        this.selectedTotal = total;
        this.checkedRowCount = checkedTotal;
    }

    handleSave(event) {
        let data = JSON.parse(JSON.stringify(this.data));
        let newData = new Array();
        let draftMap = new Map();
 

        event.detail.draftValues.forEach((rowUpdate) => {
            draftMap.set(Number(rowUpdate.id), rowUpdate);
        });
        console.log(draftMap);

        data.forEach((row) => {
            if (draftMap.has(row.id)) {
                newData.push(this.compareUpdate(row, draftMap.get(row.id)));
            } else {
                newData.push(row);
            }

        });
        this.data = this.fixPercentFormatting(newData);
        this.draftValues = [];

    }
    
    compareUpdate(original, update) {
        for (const prop in update) {
            
            original[prop] = (original[prop] && typeof original[prop] == 'number') ? Number(update[prop]) : update[prop];
        }
        return original;
    }


    deleteRow(row) {
        const { id } = row;
        const index = this.findRowIndexById(id);
        if (index !== -1) {
            this.data = this.data
                .slice(0, index)
                .concat(this.data.slice(index + 1));
        }
    }

    findRowIndexById(id) {
        let ret = -1;
        this.data.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

}