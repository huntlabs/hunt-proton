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
module hunt.proton.engine.SslDomain;

//import javax.net.ssl.SSLContext;
import hunt.proton.engine.impl.ssl.SslDomainImpl;
import hunt.Exceptions;

/**
 * I store the details used to create SSL sessions.
 */
interface SslDomain
{

    class Factory
    {
        public static SslDomain create() {
            implementationMissing(false);
           // return new SslDomainImpl();
            return null;
        }
    }

    /**
     * Determines whether the endpoint acts as a client or server.
     */
    enum Mode
    {
        /** Local connection endpoint is an SSL client */
        CLIENT,

        /** Local connection endpoint is an SSL server */
        SERVER
    }

    /**
     * Determines the level of peer validation.
     *
     * {@link #VERIFY_PEER_NAME} is used by default in {@link Mode#CLIENT client}
     * mode if not configured otherwise, with {@link #ANONYMOUS_PEER} used for
     * {@link Mode#SERVER server} mode if not configured otherwise.
     */
    public enum VerifyMode
    {
        /**
         * Requires peers provide a valid identifying certificate signed by
         * a trusted certificate. Does not verify hostname details of the
         * peer certificate, use {@link #VERIFY_PEER_NAME} for this instead.
         */
        VERIFY_PEER,
        /**
         * Requires peers provide a valid identifying certificate signed
         * by a trusted certificate, including verifying hostname details
         * of the certificate using peer details provided when configuring
         * TLS via {@link Transport#ssl(SslDomain, SslPeerDetails)}.
         */
        VERIFY_PEER_NAME,
        /**
         * does not require a valid certificate, and permits use of ciphers that
         * do not provide authentication
         */
        ANONYMOUS_PEER,
    }

    /**
     * Initialize the ssl domain object.
     *
     * An SSL object be either an SSL server or an SSL client. It cannot be both. Those
     * transports that will be used to accept incoming connection requests must be configured
     * as an SSL server. Those transports that will be used to initiate outbound connections
     * must be configured as an SSL client.
     *
     */
    void init(Mode mode);

    Mode getMode();

    /**
     * Set the certificate that identifies the local node to the remote.
     *
     * This certificate establishes the identity for the local node. It will be sent to the
     * remote if the remote needs to verify the identity of this node. This may be used for
     * both SSL servers and SSL clients (if client authentication is required by the server).
     *
     * @param certificateFile path to file/database containing the identifying
     * certificate.
     * @param privateKeyFile path to file/database containing the private key used to
     * sign the certificate
     * @param password the password used to sign the key, else null if key is not
     * protected.
     */
    void setCredentials(string certificateFile, string privateKeyFile, string password);

    string getPrivateKeyFile();

    string getPrivateKeyPassword();

    string getCertificateFile();

    /**
     * Configure the set of trusted CA certificates used by this node to verify peers.
     *
     * If the local SSL client/server needs to verify the identity of the remote, it must
     * validate the signature of the remote's certificate. This function sets the database of
     * trusted CAs that will be used to verify the signature of the remote's certificate.
     *
     * @param certificateDb database of trusted CAs, used to authenticate the peer.
     */
    void setTrustedCaDb(string certificateDb);

    string getTrustedCaDb();

    /**
     * Configure the level of verification used on the peer certificate.
     *
     * This method controls how the peer's certificate is validated, if at all. By default,
     * neither servers nor clients attempt to verify their peers ({@link VerifyMode#ANONYMOUS_PEER}).
     * Once certificates and trusted CAs are configured, peer verification can be enabled.
     *
     * In order to verify a peer, a trusted CA must be configured. See
     * {@link #setTrustedCaDb(String)}.
     *
     * NOTE: Servers must provide their own certificate when verifying a peer. See
     * {@link #setCredentials(String, String, String)}).
     *
     * @param mode the level of validation to apply to the peer
     */
    void setPeerAuthentication(VerifyMode mode);

    VerifyMode getPeerAuthentication();

    /**
     * Permit a server to accept connection requests from non-SSL clients.
     *
     * This configures the server to "sniff" the incoming client data stream, and dynamically
     * determine whether SSL/TLS is being used. This option is disabled by default: only
     * clients using SSL/TLS are accepted.
     */
    void allowUnsecuredClient(bool allowUnsecured);

    bool allowUnsecuredClient();

    /**
     * Sets an SSLContext for use when establishing SSL transport. Setting a context this way overrides alternate
     * configuration that might otherwise have been used to create a context, such as key and trust store paths.
     *
     *@param sslContext the context to use
     */
    //TODO
   // void setSslContext(SSLContext sslContext);

    /**
     * Returns the SSLContext set by {@link #setSslContext(SSLContext)}.
     *
     * @return the SSLContext, or null if none was set.
     */
    //TODO
   // SSLContext getSslContext();
}
