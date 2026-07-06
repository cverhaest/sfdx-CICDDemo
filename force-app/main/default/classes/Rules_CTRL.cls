public class Rules_CTRL {
    // Call Apex Methods / Enable Client-Side Caching
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.apex
    @AuraEnabled(cacheable=true)
    public static list<public_rulestable__x> getRulesListRESTCalloutFct(string sType){
        system.debug('### CVER - Rules_CTRL - getRulesListRESTCalloutFct - sType:' + sType);
        
        list<public_rulestable__x> lRules = new list<public_rulestable__x>();
        
        // Platform Cache principle only used by the Aura Component as LWC natively managed cache using "cacheable=true" annotation
        // Get partition
		Cache.OrgPartition TARulesCache = Cache.Org.getPartition('local.TravelApprovalRules');
        
        // Remove Rules from the cache
        for(String sKey:TARulesCache.getKeys()){
            TARulesCache.remove(sKey);
        }
        
        // Making an http request to recover Rules from the external service
        Http oHttp = new Http();
		HttpRequest oRequest = new HttpRequest();
        
        if(sType != null && sType != ''){            
            //oRequest.setEndpoint('https://restwsrules.herokuapp.com/RulesTable?type=' + sType);
            // Legacy Named Credential
            //oRequest.setEndpoint('callout:restWSRules_Credentials/RulesTable?type=' + sType);
            // Named Credential (new): https://help.salesforce.com/s/articleView?id=sf.nc_named_creds_and_ext_creds.htm&type=5
            oRequest.setEndpoint('callout:restWSRules_NamedCredential/RulesTable?type=' + sType);
            
            oRequest.setMethod('GET');
            HttpResponse oResponse = oHttp.send(oRequest);
            
            // If the request is successful, parse the JSON response.
            if (oResponse.getStatusCode() == 200) {
                system.debug('### CVER - Rules_CTRL - getRulesListRESTCalloutFct - response.getBody():' + oResponse.getBody());
                
                String sResponse = oResponse.getBody();
                
                // Standardize response string
                if (!sResponse.contains('"rows":')) {
                    if (sResponse.substring(0,1).equals('{')) {
                        sResponse = '[' + sResponse  + ']';
                    }
                    sResponse = '{"rows" : ' + sResponse + '}';
                }
                
                // Deserialize the JSON string into collections of primitive data types.
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(sResponse);
                // Cast the values in the 'animals' key as a list
                List<Object> lRowsTemp = (List<Object>) results.get('rows');
                
                for (Object oRow: lRowsTemp) {
                    system.debug('### CVER - Rules_CTRL - getRulesListRESTCalloutFct - oRow:' + oRow);
                    
                    Map<String, Object> mapRow = (Map<String, Object>)oRow;
                    
                    public_rulestable__x oRulesTemp = new public_rulestable__x(name__c = (String) mapRow.get('name'), description__c = (String) mapRow.get('description'));
                    
                    lRules.add(oRulesTemp);

                    // Platform Cache
                    Cache.Org.put('local.TravelApprovalRules.'+ (String) mapRow.get('name'), oRulesTemp);
                }
            }            
        }
        
        system.debug('### CVER - Rules_CTRL - getRulesListRESTCalloutFct - lRules.size():' + lRules.size());

        return lRules;
    }   

    // Call Apex Methods / Platform Cache
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.apex
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_cache_namespace_overview.htm
    @AuraEnabled
    public static list<public_rulestable__x> getRulesListFromCacheFct(string sType){
        system.debug('### CVER - Rules_CTRL - getRulesListFromCacheFct - sType:' + sType);
        
        list<public_rulestable__x> lRules = new list<public_rulestable__x>();
        
        // Get partition
		Cache.OrgPartition TARulesCache = Cache.Org.getPartition('local.TravelApprovalRules');
        
        // Return Rules from the cache
        for(String sKey:TARulesCache.getKeys()){
            lRules.add((public_rulestable__x) TARulesCache.get(sKey));
        }
        
        system.debug('### CVER - Rules_CTRL - getRulesListFromCacheFct - Cache - lRules.size():' + lRules.size());
        
        // Making an http request to recover Rules from the external service if cache is empty
        if(lRules.isEmpty()){
            lRules = getRulesListRESTCalloutFct(sType);
            
            system.debug('### CVER - Rules_CTRL - getRulesListFromCacheFct - Callout - lRules.size():' + lRules.size());
        }

        return lRules;
    }        

    // Call Apex Methods
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.apex
    @AuraEnabled(cacheable=true)
    public static list<public_rulestable__x> getRulesListFct(string sType){
        system.debug('### CVER - Rules_CTRL - getRulesListFct - sType:' + sType);
        
        list<public_rulestable__x> lRules = new list<public_rulestable__x>();
        
        if(sType != null && sType != ''){            
            for(public_rulestable__x oRulesTemp:[select name__c, description__c FROM public_rulestable__x WHERE type__c =:sType]){
            	lRules.add(oRulesTemp);  
                
                system.debug('### CVER - Rules_CTRL - getRulesListFct - name__c:' + oRulesTemp.name__c + ' - description__c' + oRulesTemp.description__c);
        	}
        }
        
        system.debug('### CVER - Rules_CTRL - getRulesListFct - lRules.size():' + lRules.size());

        return lRules;
    }
}