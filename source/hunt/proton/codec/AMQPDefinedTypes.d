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


module hunt.proton.codec.AMQPDefinedTypes;

import hunt.proton.codec.messaging.DataType;
import hunt.proton.codec.messaging.FooterType;
import hunt.proton.codec.messaging.HeaderType;
import hunt.proton.codec.messaging.SourceType;
import hunt.proton.codec.messaging.TargetType;
import hunt.proton.codec.messaging.AcceptedType;
import hunt.proton.codec.messaging.ModifiedType;
import hunt.proton.codec.messaging.ReleasedType;
import hunt.proton.codec.messaging.ReceivedType;
import hunt.proton.codec.messaging.RejectedType;
import hunt.proton.codec.messaging.PropertiesType;
import hunt.proton.codec.messaging.DeliveryAnnotationsType;
import hunt.proton.codec.messaging.MessageAnnotationsType;
import hunt.proton.codec.messaging.ApplicationPropertiesType;
import hunt.proton.codec.messaging.AmqpSequenceType;
import hunt.proton.codec.messaging.AmqpValueType;
import hunt.proton.codec.messaging.DeleteOnCloseType;
import hunt.proton.codec.messaging.DeleteOnNoLinksType;
import hunt.proton.codec.messaging.DeleteOnNoMessagesType;
import hunt.proton.codec.messaging.DeleteOnNoLinksOrMessagesType;
import hunt.proton.codec.messaging.FastPathHeaderType;
import hunt.proton.codec.messaging.FastPathAcceptedType;
import hunt.proton.codec.messaging.FastPathPropertiesType;
import hunt.proton.codec.messaging.FastPathDeliveryAnnotationsType;
import hunt.proton.codec.messaging.DeleteOnNoLinksOrMessagesType;
import hunt.proton.codec.messaging.FastPathMessageAnnotationsType;
import hunt.proton.codec.messaging.FastPathApplicationPropertiesType;
import hunt.proton.codec.messaging.FastPathDataType;
import hunt.proton.codec.messaging.FastPathAmqpSequenceType;
import hunt.proton.codec.messaging.FastPathAmqpValueType;
import hunt.proton.codec.messaging.FastPathFooterType;






import hunt.proton.codec.security.SaslChallengeType;
import hunt.proton.codec.security.SaslInitType;
import hunt.proton.codec.security.SaslOutcomeType;
import hunt.proton.codec.security.SaslMechanismsType;
import hunt.proton.codec.security.SaslResponseType;

import hunt.proton.codec.transaction.DeclareType;
import hunt.proton.codec.transaction.CoordinatorType;
import hunt.proton.codec.transaction.DischargeType;
import hunt.proton.codec.transaction.DeclaredType;
import hunt.proton.codec.transaction.TransactionalStateType;


import hunt.proton.codec.transport.OpenType;
import hunt.proton.codec.transport.BeginType;
import hunt.proton.codec.transport.AttachType;
import hunt.proton.codec.transport.FlowType;
import hunt.proton.codec.transport.TransferType;
import hunt.proton.codec.transport.DispositionType;
import hunt.proton.codec.transport.DetachType;
import hunt.proton.codec.transport.EndType;
import hunt.proton.codec.transport.CloseType;
import hunt.proton.codec.transport.ErrorConditionType;
import hunt.proton.codec.transport.FastPathFlowType;
import hunt.proton.codec.transport.FastPathTransferType;
import hunt.proton.codec.transport.FastPathDispositionType;
import hunt.proton.codec.Decoder;
import hunt.proton.codec.EncoderImpl;

class AMQPDefinedTypes
{
    public static void registerAllTypes(Decoder decoder, EncoderImpl encoder)
    {
        registerTransportTypes(decoder, encoder);
        registerMessagingTypes(decoder, encoder);
        registerTransactionTypes(decoder, encoder);
        registerSecurityTypes(decoder, encoder);
    }

    public static void registerTransportTypes(Decoder decoder, EncoderImpl encoder)
    {
        OpenType.register(decoder, encoder);
        BeginType.register(decoder, encoder);
        AttachType.register(decoder, encoder);
        FlowType.register(decoder, encoder);
        TransferType.register(decoder, encoder);
        DispositionType.register(decoder, encoder);
        DetachType.register(decoder, encoder);
        EndType.register(decoder, encoder);
        CloseType.register(decoder, encoder);
        ErrorConditionType.register(decoder, encoder);

        FastPathFlowType.register(decoder, encoder);
        FastPathTransferType.register(decoder, encoder);
        FastPathDispositionType.register(decoder, encoder);
    }

    public static void registerMessagingTypes(Decoder decoder, EncoderImpl encoder)
    {
        HeaderType.register(decoder, encoder);
        AcceptedType.register(decoder , encoder);
        PropertiesType.register( decoder, encoder );
        DeliveryAnnotationsType.register(decoder, encoder);
        MessageAnnotationsType.register(decoder, encoder);
        ApplicationPropertiesType.register(decoder, encoder);
        DataType.register(decoder, encoder);
        AmqpSequenceType.register(decoder, encoder);
        AmqpValueType.register(decoder, encoder);
        FooterType.register(decoder, encoder);
        ReceivedType.register(decoder, encoder);
        RejectedType.register(decoder, encoder);
        ReleasedType.register(decoder, encoder);
        ModifiedType.register(decoder, encoder);
        SourceType.register(decoder, encoder);
        TargetType.register(decoder, encoder);
        DeleteOnCloseType.register(decoder, encoder);
        DeleteOnNoLinksType.register(decoder, encoder);
        DeleteOnNoMessagesType.register(decoder, encoder);
        DeleteOnNoLinksOrMessagesType.register(decoder, encoder);

        FastPathHeaderType.register(decoder, encoder);
        FastPathAcceptedType.register(decoder , encoder);
        FastPathPropertiesType.register( decoder, encoder );
        FastPathDeliveryAnnotationsType.register(decoder, encoder);
        FastPathMessageAnnotationsType.register(decoder, encoder);
        FastPathApplicationPropertiesType.register(decoder, encoder);
        FastPathDataType.register(decoder, encoder);
        FastPathAmqpSequenceType.register(decoder, encoder);
        FastPathAmqpValueType.register(decoder, encoder);
        FastPathFooterType.register(decoder, encoder);
    }

    public static void registerTransactionTypes(Decoder decoder, EncoderImpl encoder)
    {
        CoordinatorType.register(decoder, encoder);
        DeclareType.register(decoder, encoder);
        DischargeType.register(decoder, encoder);
        DeclaredType.register(decoder, encoder);
        TransactionalStateType.register(decoder, encoder);
    }

    public static void registerSecurityTypes(Decoder decoder, EncoderImpl encoder)
    {
        SaslMechanismsType.register(decoder, encoder);
        SaslInitType.register(decoder, encoder);
        SaslChallengeType.register(decoder, encoder);
        SaslResponseType.register(decoder, encoder);
        SaslOutcomeType.register(decoder, encoder);
    }
}
