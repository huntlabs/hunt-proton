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

module hunt.proton.engine.impl.EndpointImpl;

import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.engine.EndpointState;
import hunt.proton.engine.Event;
import hunt.proton.engine.ProtonJEndpoint;
import hunt.proton.engine.Record;
import hunt.proton.engine.impl.RecordImpl;
import hunt.proton.engine.impl.ConnectionImpl;
import hunt.proton.engine.impl.TransportImpl;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;

/**
 * 
 */
class EndpointImpl : ProtonJEndpoint {
    private EndpointState _localState = EndpointState.UNINITIALIZED;
    private EndpointState _remoteState = EndpointState.UNINITIALIZED;
    private ErrorCondition _localError; //= new ErrorCondition();
    private ErrorCondition _remoteError; // = new ErrorCondition();
    private bool _modified;
    private EndpointImpl _transportNext;
    private EndpointImpl _transportPrev;
    private Object _context;
    private Record _attachments; //= new RecordImpl();

    private int refcount = 1;
    bool freed = false;

    this() {
        _localError = new ErrorCondition();
        _remoteError = new ErrorCondition();
        _attachments = new RecordImpl();
    }

    void incref() {
        refcount++;
    }

    void decref() {
        refcount--;
        if (refcount == 0) {
            postFinal();
        } else if (refcount < 0) {
            throw new IllegalStateException();
        }
    }

    abstract void postFinal();

    abstract void localOpen();

    abstract void localClose();

    void open() {
        if (getLocalState() != EndpointState.ACTIVE) {
            _localState = EndpointState.ACTIVE;
            localOpen();
            modified();
        }
    }

    void close() {
        warning(getLocalState());
        if (getLocalState() != EndpointState.CLOSED) {
            _localState = EndpointState.CLOSED;
            localClose();
            modified();
        }
    }

    EndpointState getLocalState() {
        return _localState;
    }

    EndpointState getRemoteState() {
        return _remoteState;
    }

    ErrorCondition getCondition() {
        return _localError;
    }

    void setCondition(ErrorCondition condition) {
        if (condition !is null) {
            _localError.copyFrom(condition);
        } else {
            _localError.clear();
        }
    }

    ErrorCondition getRemoteCondition() {
        return _remoteError;
    }

    void setLocalState(EndpointState localState) {
        _localState = localState;
    }

    void setRemoteState(EndpointState remoteState) {
        // TODO - check state change legal
        _remoteState = remoteState;
    }

    void modified() {
        modified(true);
    }

    void modified(bool emit) {
        if (!_modified) {
            _modified = true;
            getConnectionImpl().addModified(this);
        }

        if (emit) {
            ConnectionImpl conn = getConnectionImpl();
            TransportImpl trans = conn.getTransport();
            if (trans !is null) {
                conn.put(Type.TRANSPORT, trans);
            }
        }
    }

    protected abstract ConnectionImpl getConnectionImpl();

    void clearModified() {
        if (_modified) {
            _modified = false;
            getConnectionImpl().removeModified(this);
        }
    }

    bool isModified() {
        return _modified;
    }

    EndpointImpl transportNext() {
        return _transportNext;
    }

    EndpointImpl transportPrev() {
        return _transportPrev;
    }

    abstract void doFree();

    void free() {
        if (freed)
            return;
        freed = true;

        doFree();
        decref();
    }

    void setTransportNext(EndpointImpl transportNext) {
        _transportNext = transportNext;
    }

    void setTransportPrev(EndpointImpl transportPrevious) {
        _transportPrev = transportPrevious;
    }

    Object getContext() {
        return _context;
    }

    void setContext(Object context) {
        _context = context;
    }

    Record attachments() {
        return _attachments;
    }

}
