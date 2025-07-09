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
