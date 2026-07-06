import { LightningElement, api, track, wire } from 'lwc';
import getRulesListRESTCalloutFct from '@salesforce/apex/Rules_CTRL.getRulesListRESTCalloutFct';
// import getRulesListRESTCalloutFct from '@salesforce/apex/Rules_CTRL.getRulesListFct';
// import getRulesListFromCacheFct from '@salesforce/apex/Rules_CTRL.getRulesListFromCacheFct';
import { refreshApex } from '@salesforce/apex';

// Access Labels
// https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.create_labels
import GRC_Rule from '@salesforce/label/c.GRC_Rule';
import GRC_Rules from '@salesforce/label/c.GRC_Rules';

export default class Rules_LWC extends LightningElement {
   // Public Properties / Public Reactive Properties
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.reactivity_public
    @api debug = false;

    // Make a Component Aware of Its Record Context
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.use_record_context
    @api recordId;

    // Make a Component Aware of Its Object Context
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.use_object_context
    @api objectApiName;

    // Access Labels
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.create_labels
    // Expose the labels to use in the template.
    // Private Properties
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.js_props_private
    label = {
        GRC_Rule,
        GRC_Rules
    };


    // Public Properties / Public Reactive Properties
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.js_props_public
    @api ruleType;

    // Tracked Properties / Private Reactive Properties
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.js_props_private_reactive
    @track error;
    
    // Call Apex Methods - Wire an Apex Method to a Function
    // To use @wire to call an Apex method, you must set cacheable=true.
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.apex
    // Render Lists
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.create_lists
    wiredRulesResult = [{}];
    @track lRules = [];

    @wire(getRulesListRESTCalloutFct, 
        { sType : '$ruleType'}
    )
    wiredGetRulesListRESTCalloutFct(result) {
        if(this.debug) console.log('### Rules_LWC - wiredGetRulesListRESTCalloutFct() - START');
        if(this.debug) console.log('### Rules_LWC - wiredGetRulesListRESTCalloutFct() - result:' + result);

        this.wiredRulesResult = result;

        if (result.data) {
            this.lRules = result.data;

            if(this.debug) console.log('### Rules_LWC - wiredGetRulesListRESTCalloutFct() - lRules:' + this.lRules);
            if(this.debug) console.log('### Rules_LWC - wiredGetRulesListRESTCalloutFct() - lRules.length' + this.lRules.length);
        } else if (result.error) {
            this.error = result.error;
        }
        if(this.debug) console.log('### Rules_LWC - wiredGetRulesListRESTCalloutFct() - END');
    }

    // Call Apex Methods - Call an Apex Method Imperatively
    // To call an Apex method imperatively, you can choose to set cacheable=true. This setting caches the result on the client, and prevents Data Manipulation Language (DML) operations.
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.apex
    // Run Code When a Component Is Inserted or Removed from the DOM
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.create_lifecycle_hooks_dom 
    // You must call an Apex method imperatively as opposed to using @wire to call a method that isn’t annotated with cacheable=true (e.g. Apex Method with Platform Cache)
    /*connectedCallback() {
        console.log('### Rules_LWC - connectedCallback() - START');

        getRulesListFromCacheFct({ sType : this.ruleType})
            .then(result => {
                this.lRules = result;

                console.log('lRules:' + this.lRules);
                console.log('lRules.length' + this.lRules.length);
            })
            .catch(error => {
                this.error = error;
            }); 

        console.log('### Rules_LWC - connectedCallback() - END');
    }*/
    
    // Refresh the Cache
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.apex
    handleRefresh(e) {
        if(this.debug) console.log('### Rules_LWC - handleRefresh() - START');

        return refreshApex(this.wiredRulesResult);
    }    
}