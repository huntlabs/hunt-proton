module hunt.proton.Proton;

import hunt.proton.amqp.messaging.ApplicationProperties;
import hunt.proton.amqp.messaging.DeliveryAnnotations;
import hunt.proton.amqp.messaging.Footer;
import hunt.proton.amqp.messaging.Header;
import hunt.proton.amqp.messaging.MessageAnnotations;
import hunt.proton.amqp.messaging.Properties;
import hunt.proton.amqp.messaging.Section;
import hunt.proton.codec.Codec;
import hunt.proton.codec.Data;
import hunt.proton.engine.Collector;
import hunt.proton.engine.Connection;
import hunt.proton.engine.Engine;
import hunt.proton.engine.Handler;
import hunt.proton.engine.SslDomain;
import hunt.proton.engine.SslPeerDetails;
import hunt.proton.engine.Transport;
import hunt.proton.message.Message;
import hunt.proton.engine.Reactor;
import hunt.Exceptions;
//import hunt.proton.reactor.ReactorOptions;

class Proton
{
    this ()
    {
    }

    public static Collector collector()
    {
        return Engine.collector();
    }

    public static Connection connection()
    {
        return Engine.connection();
    }

    public static Transport transport()
    {
        return Engine.transport();
    }

    public static SslDomain sslDomain()
    {
        return Engine.sslDomain();
    }

    public static SslPeerDetails sslPeerDetails(string hostname, int port)
    {
        return Engine.sslPeerDetails(hostname, port);
    }

    public static Data data(long capacity)
    {
        return Codec.data(capacity);
    }

    public static Message message()
    {
        return Message.Factory.create();
    }

    public static Message message(Header header,
                      DeliveryAnnotations deliveryAnnotations, MessageAnnotations messageAnnotations,
                      Properties properties, ApplicationProperties applicationProperties,
                      Section bd, Footer footer)
    {
        return Message.Factory.create(header, deliveryAnnotations,
                                      messageAnnotations, properties,
                                      applicationProperties, bd, footer);
    }

    public static Reactor reactor(){
       // return Reactor.Factory.create();
        implementationMissing(false);
        return null;
    }

    public static Reactor reactor(Handler[] handlers)
    {
      implementationMissing(false);
      return null;
        //Reactor reactor = Reactor.Factory.create();
        //foreach (Handler handler ; handlers) {
        //    reactor.getHandler().add(handler);
        //}
        //return reactor;
    }

    //public static Reactor reactor(ReactorOptions options)
    //{
    //    return Reactor.Factory.create(options);
    //}
    //
    //public static Reactor reactor(ReactorOptions options, Handler [] handlers)
    //{
    //    Reactor reactor = Reactor.Factory.create(options);
    //    foreach (Handler handler ; handlers) {
    //        reactor.getHandler().add(handler);
    //    }
    //    return reactor;
    //}
}


