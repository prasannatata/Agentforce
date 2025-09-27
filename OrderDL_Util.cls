public with sharing class OrderDL_Util {

    // === Helper DTO for Rollups ===
    public class Tot {
        public Integer count {get; set;}
        public Decimal revenue {get; set;}
        public Tot() {
            count = 0;
            revenue = 0;
        }
    }

    // === Format single order "card" ===
    public static String fmtOrderCard(Realistic_OrderLine_Datacsv__dlm o) {
        List<String> lines = new List<String>{
            'Order Ref: ' + o.OrderRefNumber__c,
            'Status: ' + o.OrderStatus__c,
            'Customer: ' + o.CustomerName__c + ' (' + o.CustomerID__c + ')',
            'Vendor: ' + o.Vendor__c,
            'Modality: ' + o.Modality__c,
            'OEM: ' + o.OEM__c,
            'Part: ' + o.PartNumber__c + ' – ' + o.PartDescription__c,
            'Sales Rep: ' + o.SalesRep__c,
            'Quantity: ' + String.valueOf(o.Quantity__c),
            'Revenue: $' + String.valueOf(o.Revenue__c),
            'Created: ' + String.valueOf(o.OrderCreateDate__c) +
                ' | PO Date: ' + String.valueOf(o.OrderPODate__c)
        };
        return String.join(lines, '\n') + '\n';
    }

    // === Format table of orders ===
    public static String fmtOrdersTable(List<Realistic_OrderLine_Datacsv__dlm> rows, String title) {
        String out = '## ' + title + '\n\n';
        out += 'OrderRef | Customer | Status | Modality | Vendor | Qty | Revenue \n';
        out += '--- | --- | --- | --- | --- | --- | --- \n';

        for (Realistic_OrderLine_Datacsv__dlm r : rows) {
            out += r.OrderRefNumber__c + ' | ' +
                   r.CustomerName__c + ' | ' +
                   r.OrderStatus__c + ' | ' +
                   r.Modality__c + ' | ' +
                   r.Vendor__c + ' | ' +
                   String.valueOf(r.Quantity__c) + ' | $' +
                   String.valueOf(r.Revenue__c) + '\n';
        }
        return out;
    }

    // === Rollup helper ===
    public static Map<String, Tot> rollup(List<Realistic_OrderLine_Datacsv__dlm> rows, String byField) {
        Map<String, Tot> totals = new Map<String, Tot>();

        for (Realistic_OrderLine_Datacsv__dlm r : rows) {
            String key;
            if (byField == 'Vendor') key = r.Vendor__c;
            else if (byField == 'Modality') key = r.Modality__c;
            else if (byField == 'Customer') key = r.CustomerName__c;
            else if (byField == 'OEM') key = r.OEM__c;
            else key = 'Unknown';

            if (!totals.containsKey(key)) {
                totals.put(key, new Tot());
            }

            Tot t = totals.get(key);
            t.count += (r.Quantity__c != null) ? Integer.valueOf(r.Quantity__c) : 1;
            t.revenue += (r.Revenue__c != null) ? r.Revenue__c : 0;
        }
        return totals;
    }

    // === Format rollup as Markdown table ===
    public static String fmtRollupTable(Map<String, Tot> totals, String title, String keyLabel) {
        String out = '## ' + title + '\n\n';
        out += keyLabel + ' | Order Count | Total Revenue \n';
        out += '--- | --- | --- \n';

        for (String k : totals.keySet()) {
            Tot t = totals.get(k);
            out += k + ' | ' + String.valueOf(t.count) + ' | $' + String.valueOf(t.revenue) + '\n';
        }
        return out;
    }
}
