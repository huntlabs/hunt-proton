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

module hunt.proton.engine.Task;

import hunt.proton.engine.Event;
import hunt.proton.engine.Extendable;
import hunt.proton.engine.Handler;
import hunt.proton.engine.Reactor;

/**
 * Represents work scheduled with a {@link Reactor} for execution at
 * some point in the future.
 * <p>
 * Tasks are created using the {@link Reactor#schedule(int, Handler)}
 * method.
 */
interface Task : Extendable {

    /**
     * @return the deadline at which the handler associated with the scheduled
     *         task should be delivered a {@link Type#TIMER_TASK} event.
     */
    long deadline();

    /** @return the reactor that created this task. */
    Reactor getReactor();

    /**
     * Cancel the execution of this task. No-op if invoked after the task was already executed.
     */
    void cancel();
}
