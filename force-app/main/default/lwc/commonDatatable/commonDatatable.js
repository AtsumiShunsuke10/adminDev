import { LightningElement, api } from 'lwc';

export default class CommonDatatable extends LightningElement {
    @api keyfield;
    @api records;
    @api columns;
    @api now;
    @api height;
    @api sortFieldNameMap;
    @api sortedDirection;
    @api sortedBy;
    elm;

    setHeight() {
        this.elm = null;
        if (this.height) {
            this.elm = this.template.querySelector('div');
            if (this.elm.clientHeight > parseInt(this.height.slice(0, -2))) {
                this.elm.style.height = this.height;
            }
        }
    }

    connectedCallback() {
        this.now = Date.now();
    }

    renderedCallback() {
        this.setHeight();
    }

    sortData(fieldname, direction) {
        let sortingData = JSON.parse(JSON.stringify(this.records));
        let sortFieldNameMap = JSON.parse(JSON.stringify(this.sortFieldNameMap));

        if (sortFieldNameMap[fieldname]) {
            fieldname = sortFieldNameMap[fieldname];
        }

        let keyValue = (a) => {
            return a[fieldname];
        };

        sortingData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

            return (direction === 'asc') ? x.localeCompare(y, 'ja') : y.localeCompare(x, 'ja');
        });
        this.records = sortingData;
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.sortData(this.sortedBy, this.sortedDirection);
    }

    handleRefresh() {
        this.now = Date.now();
        this.dispatchEvent(new CustomEvent('refresh'));
    }
}