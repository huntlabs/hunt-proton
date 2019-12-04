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

module hunt.proton.engine.Link;

import hunt.collection.Map;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.ReceiverSettleMode;
import hunt.proton.amqp.transport.SenderSettleMode;
import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.transport.Target;
import hunt.proton.engine.Endpoint;
import hunt.proton.engine.Delivery;
import hunt.proton.engine.Session;
import hunt.collection.Set;
import hunt.proton.engine.EndpointState;
/**
 * Link
 *
 * The settlement mode defaults are:
 *
 * Sender settle mode - {@link SenderSettleMode#MIXED}.
 * Receiver settle mode - {@link ReceiverSettleMode#FIRST}
 *
 * TODO describe the application's responsibility to honour settlement.
 */
interface Link : Endpoint
{

    /**
     * Returns the name of the link
     *
     * @return the link name
     */
    string getName();

    /**
     * Create a delivery object based on the specified tag and adds it to the
     * this link's delivery list and its connection work list.
     *
     * TODO to clarify - this adds the delivery to the connection list.  It is not yet
     * clear why this is done or if it is useful for the application to be able to discover
     * newly created deliveries from the {@link Connection#getWorkHead()}.
     *
     * @param tag a tag for the delivery
     * @return a new Delivery object
     */
    public Delivery delivery(byte[] tag);

    /**
     * Create a delivery object based on the specified tag. This form
     * of the method is intended to allow the tag to be formed from a
     * subsequence of the byte array passed in. This might allow more
     * optimisation options in future but at present is not
     * implemented.
     *
     * @param tag a tag for the delivery
     * @param offset (currently ignored and must be 0)
     * @param length (currently ignored and must be the length of the <code>tag</code> array
     * @return a Delivery object
     */
    public Delivery delivery(byte[] tag, int offset, int length);

    /**
     * Returns the head delivery on the link.
     */
    Delivery head();

    /**
     * Returns the current delivery
     */
    Delivery current();

    /**
     * Attempts to advance the current delivery. Advances it to the next delivery if one exists, else null.
     *
     * The behaviour of this method is different for senders and receivers.
     *
     * @return true if it can advance, false if it cannot
     *
     * TODO document the meaning of the return value more fully. Currently Senderimpl only returns false if there is no current delivery
     */
    bool advance();


    Source getSource();
    Target getTarget();

    /**
     * Sets the source for this link.
     *
     * The initiator of the link must always provide a Source.
     *
     * An application responding to the creation of the link should perform an application
     * specific lookup on the {@link #getRemoteSource()} to determine an actual Source. If it
     * failed to determine an actual source, it should set null, and then go on to {@link #close()}
     * the link.
     *
     * @see "AMQP Spec 1.0 section 2.6.3"
     */
    void setSource(Source address);

    /**
     * Expected to be used in a similar manner to {@link #setSource(Source)}
     */
    void setTarget(Target address);

    /**
     * @see #setSource(Source)
     */
    Source getRemoteSource();

    /**
     * @see #setTarget(Target)
     */
    Target getRemoteTarget();

    public Link next(Set!EndpointState local, Set!EndpointState remote);

    /**
     * Gets the credit balance for a link.
     *
     * Note that a sending link may still be used to send deliveries even if
     * link credit is/reaches zero, however those deliveries will end up being
     * {@link #getQueued() queued} by the link until enough credit is obtained
     * from the receiver to send them over the wire. In this case the balance
     * reported will go negative.
     *
     * @return the credit balance for the link
     */
    public int getCredit();

    /**
     * Gets the number of queued messages for a link.
     *
     * Links may queue deliveries for a number of reasons, for example there may be insufficient
     * {@link #getCredit() credit} to send them to the receiver, they may not have yet had a chance
     * to be written to the wire, or the receiving application has simply not yet processed them.
     *
     * @return the queued message count for the link
     */
    public int getQueued();

    public int getUnsettled();

    public Session getSession();

    SenderSettleMode getSenderSettleMode();

    /**
     * Sets the sender settle mode.
     *
     * Should only be called during link set-up, i.e. before calling {@link #open()}.
     *
     * If this endpoint is the initiator of the link, this method can be used to set a value other than
     * the default.
     *
     * If this endpoint is not the initiator, this method should be used to set a local value. According
     * to the AMQP spec, the application may choose to accept the sender's suggestion
     * (accessed by calling {@link #getRemoteSenderSettleMode()}) or choose another value. The value
     * has no effect on Proton, but may be useful to the application at a later point.
     *
     * In order to be AMQP compliant the application is responsible for honouring the settlement mode. See {@link Link}.
     */
    void setSenderSettleMode(SenderSettleMode senderSettleMode);

    /**
     * @see #setSenderSettleMode(SenderSettleMode)
     */
    SenderSettleMode getRemoteSenderSettleMode();

    ReceiverSettleMode getReceiverSettleMode();

    /**
     * Sets the receiver settle mode.
     *
     * Used in analogous way to {@link #setSenderSettleMode(SenderSettleMode)}
     */
    void setReceiverSettleMode(ReceiverSettleMode receiverSettleMode);

    /**
     * @see #setReceiverSettleMode(ReceiverSettleMode)
     */
    ReceiverSettleMode getRemoteReceiverSettleMode();

    /**
     * TODO should this be part of the interface?
     */
    void setRemoteSenderSettleMode(SenderSettleMode remoteSenderSettleMode);

    /**
     * Gets the local link properties.
     *
     * @see #setProperties(Map)
     */
    Map!(Symbol, Object) getProperties();

    /**
     * Sets the local link properties, to be conveyed to the peer via the Attach frame when
     * attaching the link to the session.
     *
     * Must be called during link setup, i.e. before calling the {@link #open()} method.
     */
    void setProperties(Map!(Symbol, Object) properties);

    /**
     * Gets the remote link properties, as conveyed from the peer via the Attach frame
     * when attaching the link to the session.
     *
     * @return the properties Map conveyed by the peer, or null if there was none.
     */
    Map!(Symbol, Object) getRemoteProperties();

    public int drained();

    /**
     * Returns a [locally generated] view of credit at the remote peer by considering the
     * current link {@link #getCredit() credit} count as well as the effect of
     * any locally {@link #getQueued() queued} messages.
     *
     * @return view of effective remote credit
     */
    public int getRemoteCredit();

    public bool getDrain();

    public void detach();
    public bool detached();

    /**
     * Sets the local link offered capabilities, to be conveyed to the peer via the Attach frame
     * when attaching the link to the session.
     *
     * Must be called during link setup, i.e. before calling the {@link #open()} method.
     *
     * @param offeredCapabilities
     *          the offered capabilities array to send, or null for none.
     */
    public void setOfferedCapabilities(Symbol[] offeredCapabilities);

    /**
     * Gets the local link offered capabilities.
     *
     * @return the offered capabilities array, or null if none was set.
     *
     * @see #setOfferedCapabilities(Symbol[])
     */
    Symbol[] getOfferedCapabilities();

    /**
     * Gets the remote link offered capabilities, as conveyed from the peer via the Attach frame
     * when attaching the link to the session.
     *
     * @return the offered capabilities array conveyed by the peer, or null if there was none.
     */
    Symbol[] getRemoteOfferedCapabilities();

    /**
     * Sets the local link desired capabilities, to be conveyed to the peer via the Attach frame
     * when attaching the link to the session.
     *
     * Must be called during link setup, i.e. before calling the {@link #open()} method.
     *
     * @param desiredCapabilities
     *          the desired capabilities array to send, or null for none.
     */
    public void setDesiredCapabilities(Symbol[] desiredCapabilities);

    /**
     * Gets the local link desired capabilities.
     *
     * @return the desired capabilities array, or null if none was set.
     *
     * @see #setDesiredCapabilities(Symbol[])
     */
    Symbol[] getDesiredCapabilities();

    /**
     * Gets the remote link desired capabilities, as conveyed from the peer via the Attach frame
     * when attaching the link to the session.
     *
     * @return the desired capabilities array conveyed by the peer, or null if there was none.
     */
    Symbol[] getRemoteDesiredCapabilities();

    /**
     * Sets the local link max message size, to be conveyed to the peer via the Attach frame
     * when attaching the link to the session. Null or 0 means no limit.
     *
     * Must be called during link setup, i.e. before calling the {@link #open()} method.
     *
     * @param maxMessageSize
     *            the local max message size value, or null to clear. 0 also means no limit.
     */
    void setMaxMessageSize(UnsignedLong maxMessageSize);

    /**
     * Gets the local link max message size.
     *
     * @return the local max message size, or null if none was set. 0 also means no limit.
     *
     * @see #setMaxMessageSize(UnsignedLong)
     */
    UnsignedLong getMaxMessageSize();

    /**
     * Gets the remote link max message size, as conveyed from the peer via the Attach frame
     * when attaching the link to the session.
     *
     * @return the remote max message size conveyed by the peer, or null if none was set. 0 also means no limit.
     */
    UnsignedLong getRemoteMaxMessageSize();
}
