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

module hunt.proton.engine.SaslListener;
import hunt.proton.engine.Transport;
import hunt.proton.engine.Sasl;
/**
 * Listener for SASL frame arrival to facilitate relevant handling for the SASL
 * negotiation.
 *
 * See the AMQP specification
 * <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-security-v1.0-os.html#doc-idp51040">
 * SASL negotiation process</a> overview for related detail.
 */
interface SaslListener {

    /**
     * Called when a sasl-mechanisms frame has arrived and its effect
     * applied, indicating the offered mechanisms sent by the 'server' peer.
     *
     * @param sasl the Sasl object
     * @param transport the related transport
     */
    void onSaslMechanisms(Sasl sasl, Transport transport);

    /**
     * Called when a sasl-init frame has arrived and its effect
     * applied, indicating the selected mechanism and any hostname
     * and initial-response details from the 'client' peer.
     *
     * @param sasl the Sasl object
     * @param transport the related transport
     */
    void onSaslInit(Sasl sasl, Transport transport);

    /**
     * Called when a sasl-challenge frame has arrived and its effect
     * applied, indicating the challenge sent by the 'server' peer.
     *
     * @param sasl the Sasl object
     * @param transport the related transport
     */
    void onSaslChallenge(Sasl sasl, Transport transport);

    /**
     * Called when a sasl-response frame has arrived and its effect
     * applied, indicating the response sent by the 'client' peer.
     *
     * @param sasl the Sasl object
     * @param transport the related transport
     */
    void onSaslResponse(Sasl sasl, Transport transport);

    /**
     * Called when a sasl-outcome frame has arrived and its effect
     * applied, indicating the outcome and any success additional-data
     * sent by the 'server' peer.
     *
     * @param sasl the Sasl object
     * @param transport the related transport
     */
    void onSaslOutcome(Sasl sasl, Transport transport);
}
