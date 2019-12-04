/*
 * hunt-proton: AMQP Protocol library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net
 *
 * Licensed under the Apache-2.0 License.
 *
 */
module hunt.proton.engine.Ssl;

/**
 * I represent the details of a particular SSL session.
 */
interface Ssl
{
    /**
     * Get the name of the Cipher that is currently in use.
     *
     * Gets a text description of the cipher that is currently active, or returns null if SSL
     * is not active (no cipher). Note that the cipher in use may change over time due to
     * renegotiation or other changes to the SSL state.
     *
     * @return the name of the cipher in use, or null if none
     */
    string getCipherName();

    /**
     * Get the name of the SSL protocol that is currently in use.
     *
     * Gets a text description of the SSL protocol that is currently active, or null if SSL
     * is not active. Note that the protocol may change over time due to renegotiation.
     *
     * @return the name of the protocol in use, or null if none
     */
    string getProtocolName();

    void setPeerHostname(string hostname);

    string getPeerHostname();
}
