import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class FaqTile extends NavigationMixin(LightningElement) {
    @api faq;
    @api caseid;
    faqHistory;
    menuItemLabel;


    handleClick(event) {
        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage", 
            attributes: {
                recordId: this.faq.Id, 
                objectApiName: "FAQ__c", 
                actionName: "view"
            }
        });
    }

    handleMouseOver(event) {
        event.stopPropagation();
        this.template.querySelector('c-faq-popover').show(event.layerY, event.layerX, this.faq);
	}

    handleMouseOut(event) {
        event.stopPropagation();
        this.template.querySelector('c-faq-popover').hide();
    }
}