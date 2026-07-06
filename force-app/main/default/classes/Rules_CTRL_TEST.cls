@isTest
public class Rules_CTRL_TEST {

    // -------------------------------------
    // getRulesListFctTest() method
    // -------------------------------------  
    static testMethod void getRulesListFctTest() {
        // public_rulestable__x Data
        //public_rulestable__x oRule = new public_rulestable__x(name__c='Rule1Test', type__c='TypeTest', description__c='DescriptionTest');
        //Database.insertImmediate(oRule);
        
        // Rules controller test
        list<public_rulestable__x> lRules = new list<public_rulestable__x>();
        lRules = Rules_CTRL.getRulesListFct('TypeTest');

        System.assertEquals(lRules.size(), 0);
        
        //Database.deleteImmediate(oRule);
    }
}