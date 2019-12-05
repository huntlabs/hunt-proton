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


module hunt.proton.amqp.transport.Role;

import hunt.Enum;
import  std.concurrency : initOnce;
import hunt.Boolean;
import hunt.Exceptions;
import hunt.util.Common;
import hunt.util.Comparator;

class Role  {

  protected string _name;

    static Role  SENDER() {
        __gshared Role  inst;
        return initOnce!inst(new Role("SENDER",0));
    }

    static Role  RECEIVER() {
        __gshared Role  inst;
        return initOnce!inst(new Role("RECEIVER",1));
    }


  this(string name, int ordinal) {
    this._name = name;
    this._ordinal = ordinal;
  }

  /**
     * The name of this enum constant, as declared in the enum declaration.
     * Most programmers should use the {@link #toString} method rather than
     * accessing this field.
     */


  /**
     * Returns the name of this enum constant, exactly as declared in its
     * enum declaration.
     *
     * <b>Most programmers should use the {@link #toString} method in
     * preference to this one, as the toString method may return
     * a more user-friendly name.</b>  This method is designed primarily for
     * use in specialized situations where correctness depends on getting the
     * exact name, which will not vary from release to release.
     *
     * @return the name of this enum constant
     */
  final string name() {
    return _name;
  }

  /**
     * The ordinal of this enumeration constant (its position
     * in the enum declaration, where the initial constant is assigned
     * an ordinal of zero).
     *
     * Most programmers will have no use for this field.  It is designed
     * for use by sophisticated enum-based data structures, such as
     * {@link java.util.EnumSet} and {@link java.util.EnumMap}.
     */
  protected int _ordinal;

  /**
     * Returns the ordinal of this enumeration constant (its position
     * in its enum declaration, where the initial constant is assigned
     * an ordinal of zero).
     *
     * Most programmers will have no use for this method.  It is
     * designed for use by sophisticated enum-based data structures, such
     * as {@link java.util.EnumSet} and {@link java.util.EnumMap}.
     *
     * @return the ordinal of this enumeration constant
     */
  final int ordinal() {
    return _ordinal;
  }

  /**
     * Returns the name of this enum constant, as contained in the
     * declaration.  This method may be overridden, though it typically
     * isn't necessary or desirable.  An enum type should override this
     * method when a more "programmer-friendly" string form exists.
     *
     * @return the name of this enum constant
     */
  override string toString() {
    return _name;
  }

    public Boolean getValue()
    {
        return new Boolean (this.name() == "RECEIVER");
    }

    public int getVal()
    {
        return this._ordinal;
    }


  override int opCmp(Object o) {
    Role other = cast(Role) o;
    Role self = this;
    if (other is null)
      throw new NullPointerException();
    return compare(self.ordinal, other.ordinal);
  }

    //int opCmp(int o)
    //{
    //    return this._val - o;
    //}



    // SENDER, RECEIVER
}



