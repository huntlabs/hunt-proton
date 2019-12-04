module NoLocalType;

import std.stdio;
import hunt.proton.amqp.DescribedType;
import hunt.proton.amqp.UnsignedLong;
import hunt.String;

 class NoLocalType : DescribedType {

  //  public NoLocalType NO_LOCAL ;

    public UnsignedLong DESCRIPTOR_CODE ;

    private  String noLocal;

    this() {
        this.noLocal =  new String ("NoLocalFilter{}");
       // NO_LOCAL =new NoLocalType();
        DESCRIPTOR_CODE = UnsignedLong.valueOf(0x0000468C00000003L);
    }

    override
    public Object getDescriptor() {
        return DESCRIPTOR_CODE;
    }

    override
    public String getDescribed() {
        return this.noLocal;
    }
}
