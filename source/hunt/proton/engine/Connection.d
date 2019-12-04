/*
 * hunt-proton: AMQP Protocol library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module hunt.proton.engine.Connection;

import hunt.collection.Set;
import hunt.collection.Map;

import hunt.proton.amqp.Symbol;
import hunt.proton.engine.impl.ConnectionImpl;
import hunt.proton.engine.Reactor;
import hunt.proton.engine.ReactorChild;
import hunt.proton.engine.Endpoint;
import hunt.proton.engine.Session;
import hunt.proton.engine.EndpointState;
import hunt.proton.engine.Link;
import hunt.proton.engine.Delivery;
import hunt.proton.engine.Collector;
import hunt.proton.engine.Transport;
/**
 * Maintains lists of sessions, links and deliveries in a state
 * that is interesting to the application.
 *
 * These are exposed by returning the head of those lists via
 * {@link #sessionHead(EnumSet, EnumSet)}, {@link #linkHead(EnumSet, EnumSet)}
 * {@link #getWorkHead()} respectively.
 */
interface Connection : Endpoint, ReactorChild
{

    public static class Factory
    {
        public static Connection create() {
            return new ConnectionImpl();
        }
    }

    /**
     * Returns a newly created session
     *
     * TODO does the Connection's channel-max property limit how many sessions can be created,
     * or opened, or neither?
     */
    public Session session();

    /**
     * Returns the head of the list of sessions in the specified states.
     *
     * Typically used to discover sessions whose remote state has acquired
     * particular values, e.g. sessions that have been remotely opened or closed.
     *
     * TODO what ordering guarantees on the returned "linked list" are provided?
     *
     * @see Session#next(EnumSet, EnumSet)
     */
    public Session sessionHead(Set!EndpointState local, Set!EndpointState remote);

    /**
     * Returns the head of the list of links in the specified states.
     *
     * Typically used to discover links whose remote state has acquired
     * particular values, e.g. links that have been remotely opened or closed.
     *
     * @see Link#next(EnumSet, EnumSet)
     */
    public Link linkHead(Set!EndpointState local, Set!EndpointState remote);

    /**
     * Returns the head of the delivery work list. The delivery work list consists of
     * unsettled deliveries whose state has been changed by the other container
     * and not yet locally processed.
     *
     * @see Receiver#recv(byte[], int, int)
     * @see Delivery#settle()
     * @see Delivery#getWorkNext()
     */
    public Delivery getWorkHead();

    public void setContainer(string container);

    public string getContainer();

    /**
     * Set the name of the host (either fully qualified or relative) to which
     * this connection is connecting to.  This information may be used by the
     * remote peer to determine the correct back-end service to connect the
     * client to.  This value will be sent in the Open performative.
     *
     * <b>Note that it is illegal to set the hostname to a numeric IP
     * address or include a port number.</b>
     *
     * @param hostname the RFC1035 compliant host name.
     */
    public void setHostname(string hostname);

    public string getHostname();

    public string getRemoteContainer();

    public string getRemoteHostname();

    void setOfferedCapabilities(Symbol[] capabilities);

    void setDesiredCapabilities(Symbol[] capabilities);

    Symbol[] getRemoteOfferedCapabilities();

    Symbol[] getRemoteDesiredCapabilities();

    Map!(Symbol,Object) getRemoteProperties();

    void setProperties(Map!(Symbol,Object) properties);

    Object getContext();

    void setContext(Object context);

    void collect(Collector collector);

    Transport getTransport();

    Reactor getReactor();
}
