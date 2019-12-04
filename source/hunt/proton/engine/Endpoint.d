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

module hunt.proton.engine.Endpoint;
import hunt.proton.engine.Extendable;
import hunt.proton.engine.EndpointState;

import hunt.proton.amqp.transport.ErrorCondition;

interface Endpoint : Extendable
{
    /**
     * @return the local endpoint state
     */
    public EndpointState getLocalState();

    /**
     * @return the remote endpoint state (as last communicated)
     */
    public EndpointState getRemoteState();

    /**
     * @return the local endpoint error, or null if there is none
     */
    public ErrorCondition getCondition();

    /**
     * Set the local error condition
     * @param condition
     */
    public void setCondition(ErrorCondition condition);

    /**
     * @return the remote endpoint error, or null if there is none
     */
    public ErrorCondition getRemoteCondition();

    /**
     * free the endpoint and any associated resources
     */
    public void free();

    /**
     * transition local state to ACTIVE
     */
    void open();

    /**
     * transition local state to CLOSED
     */
    void close();

    /**
     * Sets an arbitrary an application owned object on the end-point.  This object
     * is not used by Proton.
     */
    public void setContext(Object o);

    /**
     * @see #setContext(Object)
     */
    public Object getContext();

}
