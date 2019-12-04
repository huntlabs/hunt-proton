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

module hunt.proton.engine.Session;

import hunt.collection.Map;

import hunt.proton.amqp.Symbol;
import hunt.proton.engine.Endpoint;
import hunt.proton.engine.Sender;
import hunt.proton.engine.Receiver;
import hunt.proton.engine.EndpointState;
import hunt.collection.Set;
import hunt.proton.engine.Connection;

/**
 * Session
 *
 * Note that session level flow control is handled internally by Proton.
 */
interface Session : Endpoint
{
    /**
     * Returns a newly created sender endpoint
     */
    public Sender sender(string name);

    /**
     * Returns a newly created receiver endpoint
     */
    public Receiver receiver(string name);

    public Session next(Set!EndpointState local, Set!EndpointState remote);

    public Connection getConnection();

    public int getIncomingCapacity();

    public void setIncomingCapacity(int bytes);

    public int getIncomingBytes();

    public int getOutgoingBytes();

    public long getOutgoingWindow();

    /**
     * Sets the outgoing window size.
     *
     * @param outgoingWindowSize the outgoing window size
     */
    public void setOutgoingWindow(long outgoingWindowSize);

    /**
     * Sets the local session properties, to be conveyed to the peer via the Begin frame when
     * attaching the session to the session.
     *
     * Must be called during session setup, i.e. before calling the {@link #open()} method.
     *
     * @param properties
     *          the properties map to send, or null for none.
     */
    void setProperties(Map!(Symbol, Object) properties);

    /**
     * Gets the local session properties.
     *
     * @return the properties map, or null if none was set.
     *
     * @see #setProperties(Map)
     */
    Map!(Symbol, Object) getProperties();

    /**
     * Gets the remote session properties, as conveyed from the peer via the Begin frame
     * when opening the session.
     *
     * @return the properties Map conveyed by the peer, or null if there was none.
     */
    Map!(Symbol, Object) getRemoteProperties();

    /**
     * Sets the local session offered capabilities, to be conveyed to the peer via the Begin frame
     * when opening the session.
     *
     * Must be called during session setup, i.e. before calling the {@link #open()} method.
     *
     * @param offeredCapabilities
     *          the offered capabilities array to send, or null for none.
     */
    public void setOfferedCapabilities(Symbol[] offeredCapabilities);

    /**
     * Gets the local session offered capabilities.
     *
     * @return the offered capabilities array, or null if none was set.
     *
     * @see #setOfferedCapabilities(Symbol[])
     */
    Symbol[] getOfferedCapabilities();

    /**
     * Gets the remote session offered capabilities, as conveyed from the peer via the Begin frame
     * when opening the session.
     *
     * @return the offered capabilities array conveyed by the peer, or null if there was none.
     */
    Symbol[] getRemoteOfferedCapabilities();

    /**
     * Sets the local session desired capabilities, to be conveyed to the peer via the Begin frame
     * when opening the session.
     *
     * Must be called during session setup, i.e. before calling the {@link #open()} method.
     *
     * @param desiredCapabilities
     *          the desired capabilities array to send, or null for none.
     */
    public void setDesiredCapabilities(Symbol[] desiredCapabilities);

    /**
     * Gets the local session desired capabilities.
     *
     * @return the desired capabilities array, or null if none was set.
     *
     * @see #setDesiredCapabilities(Symbol[])
     */
    Symbol[] getDesiredCapabilities();

    /**
     * Gets the remote session desired capabilities, as conveyed from the peer via the Begin frame
     * when opening the session.
     *
     * @return the desired capabilities array conveyed by the peer, or null if there was none.
     */
    Symbol[] getRemoteDesiredCapabilities();
}
