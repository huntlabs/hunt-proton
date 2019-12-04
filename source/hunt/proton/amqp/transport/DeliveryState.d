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

module hunt.proton.amqp.transport.DeliveryState;

/**
 * Describes the state of a delivery at a link end-point.
 *
 * Note that the the sender is the owner of the state.
 * The receiver merely influences the state.
 * TODO clarify the concept of ownership? how is link recovery involved?
 */

enum DeliveryStateType {
  Accepted,
  Declared,
  Modified,
  Received,
  Rejected,
  Released,
  Transactional
}

interface DeliveryState
{
    /**
     * @return the {@link DeliveryStateType} that this instance represents.
     */
    DeliveryStateType getType();

}
