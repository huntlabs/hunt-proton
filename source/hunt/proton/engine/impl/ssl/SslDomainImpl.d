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
module hunt.proton.engine.impl.ssl.SslDomainImpl;

//import javax.net.ssl.SSLContext;
import hunt.proton.engine.ProtonJSslDomain;
import hunt.proton.engine.SslDomain;
import hunt.proton.engine.SslPeerDetails;
import hunt.proton.engine.impl.ssl.ProtonSslEngineProvider;

import hunt.proton.engine.impl.ssl.SslEngineFacadeFactory;

import hunt.proton.engine.impl.ssl.ProtonSslEngine;

//class SslDomainImpl : SslDomain, ProtonSslEngineProvider, ProtonJSslDomain
//{
//    private Mode _mode;
//    private VerifyMode _verifyMode;
//    private string _certificateFile;
//    private string _privateKeyFile;
//    private string _privateKeyPassword;
//    private string _trustedCaDb;
//    private bool _allowUnsecuredClient;
//    //private SSLContext _sslContext;
//
//    private SslEngineFacadeFactory _sslEngineFacadeFactory ;//= new SslEngineFacadeFactory();
//
//    /**
//     * Application code should use {@link hunt.proton.engine.SslDomain.Factory#create()} instead.
//     */
//    this()
//    {
//        _sslEngineFacadeFactory = new SslEngineFacadeFactory();
//    }
//
//
//    public void init(Mode mode)
//    {
//        _sslEngineFacadeFactory.resetCache();
//        _mode = mode;
//    }
//
//
//    public Mode getMode()
//    {
//        return _mode;
//    }
//
//
//    public void setCredentials(string certificateFile, string privateKeyFile, string privateKeyPassword)
//    {
//        _certificateFile = certificateFile;
//        _privateKeyFile = privateKeyFile;
//        _privateKeyPassword = privateKeyPassword;
//        _sslEngineFacadeFactory.resetCache();
//    }
//
//
//    public void setTrustedCaDb(string certificateDb)
//    {
//        _trustedCaDb = certificateDb;
//        _sslEngineFacadeFactory.resetCache();
//    }
//
//
//    public string getTrustedCaDb()
//    {
//        return _trustedCaDb;
//    }
//
//
//    //public void setSslContext(SSLContext sslContext)
//    //{
//    //    _sslContext = sslContext;
//    //}
//    //
//    //
//    //public SSLContext getSslContext()
//    //{
//    //    return _sslContext;
//    //}
//
//
//    public void setPeerAuthentication(VerifyMode verifyMode)
//    {
//        _verifyMode = verifyMode;
//        _sslEngineFacadeFactory.resetCache();
//    }
//
//
//    public VerifyMode getPeerAuthentication()
//    {
//        if(_verifyMode is null)
//        {
//           return _mode == Mode.SERVER ? VerifyMode.ANONYMOUS_PEER : VerifyMode.VERIFY_PEER_NAME;
//        }
//
//        return _verifyMode;
//    }
//
//
//    public string getPrivateKeyFile()
//    {
//        return _privateKeyFile;
//    }
//
//
//    public string getPrivateKeyPassword()
//    {
//        return _privateKeyPassword;
//    }
//
//
//    public string getCertificateFile()
//    {
//        return _certificateFile;
//    }
//
//
//    public void allowUnsecuredClient(bool allowUnsecured)
//    {
//        _allowUnsecuredClient = allowUnsecured;
//        _sslEngineFacadeFactory.resetCache();
//    }
//
//
//    public bool allowUnsecuredClient()
//    {
//        return _allowUnsecuredClient;
//    }
//
//
//    public ProtonSslEngine createSslEngine(SslPeerDetails peerDetails)
//    {
//        return _sslEngineFacadeFactory.createProtonSslEngine(this, peerDetails);
//    }
//
//
//    //public string tostring()
//    //{
//    //    stringBuilder builder = new stringBuilder();
//    //    builder.append("SslDomainImpl [_mode=").append(_mode)
//    //        .append(", _verifyMode=").append(_verifyMode)
//    //        .append(", _certificateFile=").append(_certificateFile)
//    //        .append(", _privateKeyFile=").append(_privateKeyFile)
//    //        .append(", _trustedCaDb=").append(_trustedCaDb)
//    //        .append(", _allowUnsecuredClient=").append(_allowUnsecuredClient)
//    //        .append("]");
//    //    return builder.tostring();
//    //}
//}
