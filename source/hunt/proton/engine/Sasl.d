module hunt.proton.engine.Sasl;

import hunt.proton.engine.SaslListener;
import std.concurrency : initOnce;
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

import hunt.Enum;
import hunt.String;

enum SaslState
{
    /** Pending configuration by application */
    PN_SASL_CONF,
    /** Pending SASL Init */
    PN_SASL_IDLE,
    /** negotiation in progress */
    PN_SASL_STEP,
    /** negotiation completed successfully */
    PN_SASL_PASS,
    /** negotiation failed */
    PN_SASL_FAIL
}

class SaslOutcome
{
    /** negotiation not completed */
    //enum {
    //    PN_SASL_NONE = (cast(byte)-1),
    //    /** authentication succeeded */
    //    PN_SASL_OK = (cast(byte)0),
    //    /** failed due to bad credentials */
    //    PN_SASL_AUTH = (cast(byte)1),
    //    /** failed due to a system error */
    //    PN_SASL_SYS = (cast(byte)2),
    //    /** failed due to unrecoverable error */
    //    PN_SASL_PERM = (cast(byte)3),
    //    PN_SASL_TEMP = (cast(byte)4),
    //    PN_SASL_SKIPPED = (cast(byte)5);
    //}
    static SaslOutcome  PN_SASL_NONE() {
        __gshared SaslOutcome  inst;
        return initOnce!inst(new SaslOutcome(cast(byte)-1));
    }

    static SaslOutcome  PN_SASL_OK() {
        __gshared SaslOutcome  inst;
        return initOnce!inst(new SaslOutcome(cast(byte)0));
    }

    static SaslOutcome  PN_SASL_AUTH() {
        __gshared SaslOutcome  inst;
        return initOnce!inst(new SaslOutcome(cast(byte)1));
    }

    static SaslOutcome  PN_SASL_SYS() {
        __gshared SaslOutcome  inst;
        return initOnce!inst(new SaslOutcome(cast(byte)2));
    }

    static SaslOutcome  PN_SASL_PERM() {
        __gshared SaslOutcome  inst;
        return initOnce!inst(new SaslOutcome(cast(byte)3));
    }

    static SaslOutcome  PN_SASL_TEMP() {
        __gshared SaslOutcome  inst;
        return initOnce!inst(new SaslOutcome(cast(byte)4));
    }

    static SaslOutcome  PN_SASL_SKIPPED() {
        __gshared SaslOutcome  inst;
        return initOnce!inst(new SaslOutcome(cast(byte)5));
    }

    private  byte _code;

    /** failed due to transient error */

    this(byte code)
    {
        _code = code;
    }

    public byte getCode()
    {
        return _code;
    }

    override
    bool opEquals(Object o)
    {
        SaslOutcome other = cast(SaslOutcome)o;
        if(other !is null)
        {
            if (other.getCode() == this.getCode())
            {
                return true;
            }
        }
        return false;
    }

    public static SaslOutcome[] values ()
    {
        return [PN_SASL_NONE ,PN_SASL_OK ,PN_SASL_AUTH,PN_SASL_SYS,PN_SASL_PERM,PN_SASL_TEMP,PN_SASL_SKIPPED];
    }
}

interface Sasl
{






    //public static SaslOutcome PN_SASL_NONE = SaslOutcome.PN_SASL_NONE;
    //public static SaslOutcome PN_SASL_OK = SaslOutcome.PN_SASL_OK;
    //public static SaslOutcome PN_SASL_AUTH = SaslOutcome.PN_SASL_AUTH;
    //public static SaslOutcome PN_SASL_SYS = SaslOutcome.PN_SASL_SYS;
    //public static SaslOutcome PN_SASL_PERM = SaslOutcome.PN_SASL_PERM;
    //public static SaslOutcome PN_SASL_TEMP = SaslOutcome.PN_SASL_TEMP;
    //public static SaslOutcome PN_SASL_SKIPPED = SaslOutcome.PN_SASL_SKIPPED;

    /**
     * Access the current state of the layer.
     *
     * @return The state of the sasl layer.
     */
    SaslState getState();

    /**
     * Set the acceptable SASL mechanisms for the layer.
     *
     * @param mechanisms a list of acceptable SASL mechanisms
     */
    void setMechanisms(string [] mechanisms);

    /**
     * Retrieve the list of SASL mechanisms provided by the remote.
     *
     * @return the SASL mechanisms advertised by the remote
     */
    string[] getRemoteMechanisms();

    /**
     * Set the remote hostname to indicate the host being connected to when
     * sending a SaslInit to the server.
     */
    void setRemoteHostname(string hostname);

    /**
     * Retrieve the hostname indicated by the client when sending its SaslInit.
     *
     * @return the hostname indicated by the remote client, or null if none specified.
     */
    string getHostname();

    /**
     * Determine the size of the bytes available via recv().
     *
     * Returns the size in bytes available via recv().
     *
     * @return The number of bytes available, zero if no available data.
     */
    int pending();

    /**
     * Read challenge/response/additional data sent from the peer.
     *
     * Use pending to determine the size of the data.
     *
     * @param bytes written with up to size bytes of inbound data.
     * @param offset the offset in the array to begin writing at
     * @param size maximum number of bytes that bytes can accept.
     * @return The number of bytes written to bytes, or an error code if {@literal < 0}.
     */
    int recv(byte[] bytes, int offset, int size);

    /**
     * Send challenge/response/additional data to the peer.
     *
     * @param bytes The challenge/response data.
     * @param offset the point within the array at which the data starts at
     * @param size The number of data octets in bytes.
     * @return The number of octets read from bytes, or an error code if {@literal < 0}
     */
    int send(byte[] bytes, int offset, int size);


    /**
     * Set the outcome of SASL negotiation
     *
     * Used by the server to set the result of the negotiation process.
     *
     * @param outcome the outcome of the SASL negotiation
     */
    void done(SaslOutcome outcome);


    /**
     * Configure the SASL layer to use the "PLAIN" mechanism.
     *
     * A utility function to configure a simple client SASL layer using
     * PLAIN authentication.
     *
     * @param username credential for the PLAIN authentication
     *                     mechanism
     * @param password credential for the PLAIN authentication
     *                     mechanism
     */
    void plain(String username, String password);

    /**
     * Retrieve the outcome of SASL negotiation.
     */
    SaslOutcome getOutcome();

    void client();
    void server();

    /**
     * Set whether servers may accept incoming connections
     * that skip the SASL layer negotiation.
     */
    void allowSkip(bool allowSkip);

    /**
     * Adds a listener to receive notice of frames having arrived.
     */
    void setListener(SaslListener saslListener);
}
