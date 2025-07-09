public with sharing class WebinarRecommendationService {
    @AuraEnabled(cacheable=true)
    public static String getRecommendedWebinars(
        String topicFilter,
        String webinarType,
        String audience,
        String region,
        String product
    ) {
        // Build string for topic search
        String topicSearch = '%' + topicFilter + '%';

        List<Webinar__c> webinars = [
            SELECT Name, Date__c, Topic__c, Product__c, Region__c, Webinar_Type__c, Audience__c, Link__c
            FROM Webinar__c
            WHERE Topic__c LIKE :topicSearch
            AND (Webinar_Type__c = :webinarType OR :webinarType = null)
            AND (Audience__c = :audience OR :audience = null)
            AND (Region__c = :region OR :region = null)
            AND (Product__c = :product OR :product = null)
            ORDER BY Date__c ASC
            LIMIT 3
        ];

        if (webinars.isEmpty()) {
            return 'Currently, there are no webinars matching this topic. Please check back soon for new sessions.';
        }

        String recommendations = '✨ Here are some recommended webinars for you:\n\n';

        for (Webinar__c w : webinars) {
            recommendations += '**Name:** ' + w.Name + '\n';
            if (w.Date__c != null) {
                recommendations += '**Date:** ' + String.valueOf(w.Date__c) + '\n';
            }
            if (w.Topic__c != null) {
                recommendations += '**Topic:** ' + w.Topic__c + '\n';
            }
            if (w.Product__c != null) {
                recommendations += '**Product:** ' + w.Product__c + '\n';
            }
            if (w.Region__c != null) {
                recommendations += '**Region:** ' + w.Region__c + '\n';
            }
            if (w.Webinar_Type__c != null) {
                recommendations += '**Type:** ' + w.Webinar_Type__c + '\n';
            }
            if (w.Audience__c != null) {
                recommendations += '**Audience:** ' + w.Audience__c + '\n';
            }
            if (w.Link__c != null) {
                recommendations += '[Register Here](' + w.Link__c + ')\n';
            }
            recommendations += '\n';
        }

        return recommendations;
    }
}


String result = WebinarRecommendationService.getRecommendedWebinars('Claims', null, null, null, null);
System.debug(result);





================
public with sharing class WebinarRecommendationService {
    @AuraEnabled(cacheable=true)
    public static String getRecommendedWebinars(String topicFilter, String webinarType, String audience, String region, String product) {
        String topicSearch = '%' + topicFilter + '%';
        String query = 'SELECT Name, Date__c, Topic__c, Product__c, Region__c, Webinar_Type__c, Audience__c, Link__c FROM Webinar__c WHERE Topic__c LIKE :topicSearch';
        
        if (webinarType != null) {
            query += ' AND Webinar_Type__c = :webinarType';
        }
        if (audience != null) {
            query += ' AND Audience__c = :audience';
        }
        if (region != null) {
            query += ' AND Region__c = :region';
        }
        if (product != null) {
            query += ' AND Product__c = :product';
        }
        query += ' ORDER BY Date__c ASC LIMIT 3';

        // Execute dynamic query
        List<Webinar__c> webinars = Database.query(query);

        if (webinars.isEmpty()) {
            return 'Currently, there are no webinars matching this topic. Please check back soon.';
        }

        String recommendations = '✨ Here are some recommended webinars for you:\n\n';
        for (Webinar__c w : webinars) {
            recommendations += '**Name:** ' + w.Name + '\n';
            if (w.Date__c != null) {
                recommendations += '**Date:** ' + String.valueOf(w.Date__c) + '\n';
            }
            if (w.Topic__c != null) {
                recommendations += '**Topic:** ' + w.Topic__c + '\n';
            }
            if (w.Product__c != null) {
                recommendations += '**Product:** ' + w.Product__c + '\n';
            }
            if (w.Region__c != null) {
                recommendations += '**Region:** ' + w.Region__c + '\n';
            }
            if (w.Webinar_Type__c != null) {
                recommendations += '**Type:** ' + w.Webinar_Type__c + '\n';
            }
            if (w.Audience__c != null) {
                recommendations += '**Audience:** ' + w.Audience__c + '\n';
            }
            if (w.Link__c != null) {
                recommendations += '[Register Here](' + w.Link__c + ')\n';
            }
            recommendations += '\n';
        }

        return recommendations;
    }
}

+++======
@isTest
public class WebinarRecommendationServiceTest {
    @isTest
    static void testGetRecommendedWebinars() {
        // Create sample webinars
        Webinar__c webinar1 = new Webinar__c(
            Name = 'Webinar 1',
            Topic__c = 'Claims Automation',
            Product__c = 'Waystar Automation',
            Region__c = 'US East',
            Webinar_Type__c = 'On demand',
            Audience__c = 'Clients',
            Date__c = Date.today(),
            Link__c = 'https://example.com/webinar1'
        );
        
        Webinar__c webinar2 = new Webinar__c(
            Name = 'Webinar 2',
            Topic__c = 'Denials Management',
            Product__c = 'Waystar Denials',
            Region__c = 'US West',
            Webinar_Type__c = 'Live',
            Audience__c = 'Clients',
            Date__c = Date.today().addDays(5),
            Link__c = 'https://example.com/webinar2'
        );
        
        Webinar__c webinar3 = new Webinar__c(
            Name = 'Webinar 3',
            Topic__c = 'RCM Automation',
            Product__c = 'Waystar Automation',
            Region__c = 'National',
            Webinar_Type__c = 'On demand',
            Audience__c = 'Sales',
            Date__c = Date.today().addDays(10),
            Link__c = 'https://example.com/webinar3'
        );
        
        insert new List<Webinar__c>{ webinar1, webinar2, webinar3 };
        
        // Call the method with filters
        String result = WebinarRecommendationService.getRecommendedWebinars(
            'Automation',    // topic
            null,            // webinarType
            null,            // audience
            null,            // region
            null             // product
        );
        
        System.debug('Result: ' + result);
        
        // Assertions
        System.assert(result.contains('Webinar 1'), 'Result should contain Webinar 1');
        System.assert(result.contains('Webinar 3'), 'Result should contain Webinar 3');
        System.assert(!result.contains('Webinar 2'), 'Result should not contain Webinar 2 if topic does not match');
    }
}
WebinarRecommendationServiceTest

