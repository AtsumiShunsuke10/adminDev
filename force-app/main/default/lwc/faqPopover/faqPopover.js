import { LightningElement, api } from 'lwc';

export default class FaqPopover extends LightningElement {
    @api question;
    @api answer;

    @api show(top, left, faq) {
        this.question = "<div class=\"slds-text-body_small\">"+faq.Question__c+"</div>";
        this.answer = "<div class=\"slds-text-body_small\" style=\"height: 12.5rem; overflow: hidden;\">"+faq.Answer__c+"</div>";
        const tooltip = this.template.querySelector('.faq-tooltip');
        tooltip.style.top = (top - 160).toString() + 'px';
        tooltip.style.left = (left + 20).toString() + 'px';
        tooltip.style.display = 'block';
    }

    @api hide() {
        const tooltip = this.template.querySelector('.faq-tooltip');
        tooltip.style.display = 'none';
    }
}