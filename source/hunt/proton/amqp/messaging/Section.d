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

module hunt.proton.amqp.messaging.Section;

interface Section {

    enum SectionType {
        AmqpSequence,
        AmqpValue,
        ApplicationProperties,
        Data,
        DeliveryAnnotations,
        Footer,
        Header,
        MessageAnnotations,
        Properties
    }

    /**
     * @return the {@link SectionType} that describes this instance.
     */
    SectionType getType();

}
