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
module hunt.proton.engine.TransportResultFactory;

import  hunt.proton.engine.TransportResult;
import  hunt.proton.engine.TransportResult;

import std.concurrency : initOnce;
import hunt.proton.engine.TransportException;
/**
 * Creates TransportResults.
 * Only intended for use by internal Proton classes.
 * This class resides in the api module so it can be used by both proton-j-impl and proton-jni.
 */
class TransportResultFactory
{

  //  private static  TransportResult _okResult = new TransportResultImpl(OK, null, null);


   static TransportResult  _okResult() {
       __gshared TransportResult  inst;
       return initOnce!inst(new TransportResultImpl(TransportResult.Status.OK, null, null));
   }


    //static TransportResult  ok() {
    //    __gshared TransportResult  inst;
    //    return initOnce!inst(_okResult);
    //}

    public static TransportResult ok()
    {
        return _okResult;
    }

    //static TransportResult  error(string format) {
    //    __gshared TransportResult  inst;
    //    return initOnce!inst(new TransportResultImpl(TransportResult.Status.ERROR, format, null));
    //}

    //public static TransportResult error(string format)
    //{
    //    //string errorDescription;
    //    //try
    //    //{
    //    //    errorDescription = String.format(format, args);
    //    //}
    //    //catch(IllegalFormatException e)
    //    //{
    //    //    LOGGER.log(Level.SEVERE, "Formating error in string " + format, e);
    //    //    errorDescription = format;
    //    //}
    //    return new TransportResultImpl(ERROR, format, null);
    //}

    static TransportResult error( string errorDescription)
    {
        return new TransportResultImpl(TransportResult.Status.ERROR, errorDescription, null);
    }

    //static TransportResult  error(Exception e) {
    //    __gshared TransportResult  inst;
    //    return initOnce!inst(new TransportResultImpl(TransportResult.Status.ERROR, e is null ? null : e.toString(), e));
    //}


    public static TransportResult error( Exception e)
    {
        return new TransportResultImpl(TransportResult.Status.ERROR, e is null ? null : e.toString(), e);
    }


}

class TransportResultImpl : TransportResult
{
    private  string _errorDescription;
    private  TransportResult.Status _status;
    private  Exception _exception;

    this(TransportResult.Status status, string errorDescription, Exception exception)
    {
        _status = status;
        _errorDescription = errorDescription;
        _exception = exception;
    }

    public bool isOk()
    {
        return _status == TransportResult.Status.OK;
    }

    public TransportResult.Status getStatus()
    {
        return _status;
    }

    public string getErrorDescription()
    {
        return _errorDescription;
    }

    public Exception getException()
    {
        return _exception;
    }

    public void checkIsOk()
    {
        if (!isOk())
        {
            Exception e = getException();
            if (e !is null)
            {
                throw new TransportException(e);
            }
            else
            {
                throw new TransportException(getErrorDescription());
            }
        }
    }
}
