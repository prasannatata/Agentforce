// OrderDL_Util.cls
public with sharing class OrderDL_Util {

    // == Types ==
    public class Result { public String result; public Result(String r){ result = r; } }

    // == Safe getters ==
    public static String s(Object v){ return (v == null) ? 'N/A' : String.valueOf(v); }
    public static Decimal d(Decimal v){ return (v == null) ? 0 : v; }
    public static Integer i(Integer v){ return (v == null) ? 0 : v; }

    // == Markdown helpers ==
    public static String mdHeader(String title){
        return '**' + title + '**\n\n';
    }
    public static String mdRow(List<String> cols){
        return '| ' + String.join(cols, ' | ') + ' |\n';
    }
    public static String mdRule(Integer colCount){
        List<String> bars = new List<String>();
        for(Integer c=0;c<colCount;c++) bars.add('---');
        return '| ' + String.join(bars, ' | ') + ' |\n';
    }

    // == Common SOQL selector ==
    public static String baseSelect(){
        return 'SELECT OrderRefNumber__c, OrderStatus__c, OrderCreateDate__c, OrderPODate__c,' +
               ' CustomerName__c, CustomerID__c, ParentCustomerName__c,' +
               ' Vendor__c, OEM__c, Modality__c, PartNumber__c, PartDescription__c,' +
               ' SalesRep__c, Requestor__c, Quantity__c, Revenue__c' +
               ' FROM Realistic_OrderLine_Datacsv__dlm ';
    }

    // == Format “card” for one order ==
    public static String fmtOrderCard(Realistic_OrderLine_Datacsv__dlm o){
        List<String> lines = new List<String>{
            'OrderRef: ' + s(o.OrderRefNumber__c),
            'Status: ' + s(o.OrderStatus__c),
            'Customer: ' + s(o.CustomerName__c) + ' (' + s(o.CustomerID__c) + ')',
            'Parent Customer: ' + s(o.ParentCustomerName__c),
            'Vendor: ' + s(o.Vendor__c) + ' | OEM: ' + s(o.OEM__c),
            'Modality: ' + s(o.Modality__c),
            'Part: ' + s(o.PartNumber__c) + ' • ' + s(o.PartDescription__c),
            'Sales Rep: ' + s(o.SalesRep__c) + ' | Requestor: ' + s(o.Requestor__c),
            'Quantity: ' + i(o.Quantity__c),
            'Revenue: $' + d(o.Revenue__c),
            'Created: ' + s(o.OrderCreateDate__c) + ' | PO Date: ' + s(o.OrderPODate__c)
        };
        return String.join(lines, '\n') + '\n';
    }

    // == Format a simple table ==
    public static String fmtOrdersTable(List<Realistic_OrderLine_Datacsv__dlm> rows, String title){
        String out = mdHeader(title);
        out += mdRow(new List<String>{'OrderRef','Customer','Status','Modality','Vendor','Qty','Revenue'});
        out += mdRule(7);
        for(Realistic_OrderLine_Datacsv__dlm r : rows){
            out += mdRow(new List<String>{
                s(r.OrderRefNumber__c),
                s(r.CustomerName__c),
                s(r.OrderStatus__c),
                s(r.Modality__c),
                s(r.Vendor__c),
                String.valueOf(i(r.Quantity__c)),
                '$' + String.valueOf(d(r.Revenue__c))
            });
        }
        return out;
    }

    // == Aggregation helper ==
    public class Tot{ public Integer count=0; public Decimal revenue=0; }
    public static Map<String,Tot> rollup(List<Realistic_OrderLine_Datacsv__dlm> rows, String byField){
        Map<String,Tot> map = new Map<String,Tot>();
        for(Realistic_OrderLine_Datacsv__dlm r : rows){
            String key;
            if(byField=='Vendor') key = s(r.Vendor__c);
            else if(byField=='OEM') key = s(r.OEM__c);
            else if(byField=='Modality') key = s(r.Modality__c);
            else if(byField=='Customer') key = s(r.CustomerName__c);
            else key = 'Unknown';

            if(!map.containsKey(key)) map.put(key, new Tot());
            Tot t = map.get(key);
            t.count += 1;
            t.revenue += d(r.Revenue__c);
        }
        return map;
    }
    public static String fmtRollupTable(Map<String,Tot> map, String title, String keyLabel){
        String out = mdHeader(title);
        out += mdRow(new List<String>{keyLabel,'Order Count','Total Revenue'});
        out += mdRule(3);
        for(String k : map.keySet()){
            Tot t = map.get(k);
            out += mdRow(new List<String>{k, String.valueOf(t.count), '$' + String.valueOf(t.revenue)});
        }
        return out;
    }
}
