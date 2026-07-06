@isTest
public class Rules_CTRL_TEST {

    // -------------------------------------------------------
    // HTTP Mock — intercepts callout and returns configured response
    // -------------------------------------------------------
    private class MockHttpCallout implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        public MockHttpCallout(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }

    // HTTP Mock that captures the outbound request for assertion
    private class CapturingMock implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
        public String capturedEndpoint;
        public String capturedMethod;

        public CapturingMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            this.capturedEndpoint = req.getEndpoint();
            this.capturedMethod   = req.getMethod();
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }

    // -------------------------------------------------------
    // getRulesListFct
    // -------------------------------------------------------
    @isTest
    static void getRulesListFct_UnknownType_ReturnsEmptyList() {
        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListFct('TypeTest');
        Test.stopTest();

        Assert.areEqual(0, result.size(), 'Should return empty list for unknown type');
    }

    @isTest
    static void getRulesListFct_NullType_ReturnsEmptyList() {
        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListFct(null);
        Test.stopTest();

        Assert.areEqual(0, result.size(), 'Should return empty list when type is null');
    }

    // -------------------------------------------------------
    // getRulesListRESTCalloutFct — JSON format: array (no "rows" key)
    // Response starts with "[" → wrapped in {"rows": [...]}
    // -------------------------------------------------------
    @isTest
    static void getRulesListRESTCalloutFct_ArrayResponse_ReturnsAllRules() {
        // Given
        String mockBody = '[{"name":"Rule1","description":"Desc1"},{"name":"Rule2","description":"Desc2"}]';
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, mockBody));

        // When
        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListRESTCalloutFct('Travel-Approval');
        Test.stopTest();

        // Then
        Assert.areEqual(2, result.size(), 'Should return 2 rules from JSON array response');
        Assert.areEqual('Rule1', result[0].name__c,        'First rule name should match');
        Assert.areEqual('Desc1', result[0].description__c, 'First rule description should match');
        Assert.areEqual('Rule2', result[1].name__c,        'Second rule name should match');
    }

    // -------------------------------------------------------
    // getRulesListRESTCalloutFct — JSON format: single object (no "rows" key)
    // Response starts with "{" → wrapped in [{...}] then in {"rows": [...]}
    // -------------------------------------------------------
    @isTest
    static void getRulesListRESTCalloutFct_SingleObjectResponse_ReturnsOneRule() {
        // Given
        String mockBody = '{"name":"Rule1","description":"Single rule"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, mockBody));

        // When
        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListRESTCalloutFct('Travel-Approval');
        Test.stopTest();

        // Then
        Assert.areEqual(1, result.size(),           'Should return 1 rule from single-object response');
        Assert.areEqual('Rule1', result[0].name__c, 'Rule name should match');
        Assert.areEqual('Single rule', result[0].description__c, 'Rule description should match');
    }

    // -------------------------------------------------------
    // getRulesListRESTCalloutFct — JSON format: already has "rows" key
    // Bypasses normalization, parsed directly
    // -------------------------------------------------------
    @isTest
    static void getRulesListRESTCalloutFct_RowsKeyResponse_ReturnsAllRules() {
        // Given
        String mockBody = '{"rows":[{"name":"RuleA","description":"DescA"},{"name":"RuleB","description":"DescB"},{"name":"RuleC","description":"DescC"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, mockBody));

        // When
        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListRESTCalloutFct('Travel-Approval');
        Test.stopTest();

        // Then
        Assert.areEqual(3, result.size(),             'Should return 3 rules when response contains "rows" key');
        Assert.areEqual('RuleA', result[0].name__c,   'First rule name should match');
        Assert.areEqual('RuleC', result[2].name__c,   'Third rule name should match');
    }

    // -------------------------------------------------------
    // getRulesListRESTCalloutFct — HTTP error (non-200)
    // -------------------------------------------------------
    @isTest
    static void getRulesListRESTCalloutFct_Http500_ReturnsEmptyList() {
        // Given
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(500, '{"error":"Internal Server Error"}'));

        // When
        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListRESTCalloutFct('Travel-Approval');
        Test.stopTest();

        // Then
        Assert.areEqual(0, result.size(), 'Should return empty list when HTTP status is 500');
    }

    @isTest
    static void getRulesListRESTCalloutFct_Http401_ReturnsEmptyList() {
        // Given
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(401, '{"error":"Unauthorized"}'));

        // When
        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListRESTCalloutFct('Travel-Approval');
        Test.stopTest();

        // Then
        Assert.areEqual(0, result.size(), 'Should return empty list when HTTP status is 401');
    }

    // -------------------------------------------------------
    // getRulesListRESTCalloutFct — empty API result
    // -------------------------------------------------------
    @isTest
    static void getRulesListRESTCalloutFct_EmptyArrayResponse_ReturnsEmptyList() {
        // Given
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, '[]'));

        // When
        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListRESTCalloutFct('Travel-Approval');
        Test.stopTest();

        // Then
        Assert.areEqual(0, result.size(), 'Should return empty list when API returns no rules');
    }

    // -------------------------------------------------------
    // getRulesListRESTCalloutFct — null / empty sType (callout skipped)
    // -------------------------------------------------------
    @isTest
    static void getRulesListRESTCalloutFct_NullType_ReturnsEmptyListWithoutCallout() {
        // No mock set: any accidental callout would throw a NullPointerException

        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListRESTCalloutFct(null);
        Test.stopTest();

        Assert.areEqual(0, result.size(), 'Should return empty list without callout when sType is null');
    }

    @isTest
    static void getRulesListRESTCalloutFct_EmptyType_ReturnsEmptyListWithoutCallout() {
        // No mock set: any accidental callout would throw a NullPointerException

        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListRESTCalloutFct('');
        Test.stopTest();

        Assert.areEqual(0, result.size(), 'Should return empty list without callout when sType is empty');
    }

    // -------------------------------------------------------
    // getRulesListRESTCalloutFct — endpoint and method verification
    // -------------------------------------------------------
    @isTest
    static void getRulesListRESTCalloutFct_ValidType_UsesGetMethodWithTypeInEndpoint() {
        // Given
        CapturingMock captureMock = new CapturingMock(200, '[{"name":"R1","description":"D1"}]');
        Test.setMock(HttpCalloutMock.class, captureMock);

        // When
        Test.startTest();
        Rules_CTRL.getRulesListRESTCalloutFct('Travel-Approval');
        Test.stopTest();

        // Then
        Assert.areEqual('GET', captureMock.capturedMethod, 'HTTP method should be GET');
        Assert.isTrue(
            captureMock.capturedEndpoint.contains('Travel-Approval'),
            'Endpoint should include the type parameter value'
        );
        Assert.isTrue(
            captureMock.capturedEndpoint.contains('RulesTable'),
            'Endpoint should target the RulesTable resource'
        );
    }

    // -------------------------------------------------------
    // getRulesListFromCacheFct — cache miss: cache empty → callout triggered
    // -------------------------------------------------------
    @isTest
    static void getRulesListFromCacheFct_CacheMiss_TriggersCalloutAndReturnsRules() {
        // Given — cache is empty by default; mock returns 2 rules
        String mockBody = '[{"name":"Rule1","description":"Desc1"},{"name":"Rule2","description":"Desc2"}]';
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, mockBody));

        // When
        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListFromCacheFct('Travel-Approval');
        Test.stopTest();

        // Then
        Assert.areEqual(2, result.size(),             'Should return 2 rules fetched via callout');
        Assert.areEqual('Rule1', result[0].name__c,   'First rule name should match callout response');
        Assert.areEqual('Desc1', result[0].description__c, 'First rule description should match callout response');
    }

    // -------------------------------------------------------
    // getRulesListFromCacheFct — cache hit: cache populated → no callout
    // Strategy: pre-populate cache via mock A (2 rules), then override mock B (0 rules).
    // If result has 2 rules → cache was used. If 0 → callout was triggered (failure case).
    // -------------------------------------------------------
    @isTest
    static void getRulesListFromCacheFct_CacheHit_ReturnsCachedRulesWithoutCallout() {
        // Given — populate cache via REST callout (mock A: 2 rules)
        String cacheBody = '[{"name":"CachedRule1","description":"FromCache1"},{"name":"CachedRule2","description":"FromCache2"}]';
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, cacheBody));
        Rules_CTRL.getRulesListRESTCalloutFct('Travel-Approval');

        // Override mock to return 0 rules — any accidental callout would yield an empty list
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(200, '[]'));

        // When
        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListFromCacheFct('Travel-Approval');
        Test.stopTest();

        // Then — 2 rules proves cache was served, not the override mock (which would give 0)
        Assert.areEqual(2, result.size(),
            'Should return 2 cached rules without triggering a fresh callout');
        Assert.areEqual('CachedRule1', result[0].name__c,
            'First cached rule name should match what was stored');
    }

    // -------------------------------------------------------
    // getRulesListFromCacheFct — cache miss + callout HTTP error → empty list
    // -------------------------------------------------------
    @isTest
    static void getRulesListFromCacheFct_CacheMissAndCalloutFails_ReturnsEmptyList() {
        // Given — cache empty, callout returns 500
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(500, '{"error":"Internal Server Error"}'));

        // When
        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListFromCacheFct('Travel-Approval');
        Test.stopTest();

        // Then
        Assert.areEqual(0, result.size(),
            'Should return empty list when cache is empty and callout fails');
    }

    // -------------------------------------------------------
    // getRulesListFromCacheFct — cache miss + null type → callout skipped inside getRulesListRESTCalloutFct
    // -------------------------------------------------------
    @isTest
    static void getRulesListFromCacheFct_NullType_ReturnsEmptyListWithoutCallout() {
        // No mock set: any accidental callout would throw

        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListFromCacheFct(null);
        Test.stopTest();

        Assert.areEqual(0, result.size(),
            'Should return empty list when cache is empty and sType is null');
    }

    // -------------------------------------------------------
    // getRulesListFromCacheFct — cache miss + empty type → callout skipped inside getRulesListRESTCalloutFct
    // -------------------------------------------------------
    @isTest
    static void getRulesListFromCacheFct_EmptyType_ReturnsEmptyListWithoutCallout() {
        // No mock set: any accidental callout would throw

        Test.startTest();
        List<public_rulestable__x> result = Rules_CTRL.getRulesListFromCacheFct('');
        Test.stopTest();

        Assert.areEqual(0, result.size(),
            'Should return empty list when cache is empty and sType is empty string');
    }
}
