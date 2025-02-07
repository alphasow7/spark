error id: jar:file:///C:/Users/Alpha/AppData/Local/Coursier/cache/v1/https/repo1.maven.org/maven2/org/apache/arrow/arrow-vector/0.8.0/arrow-vector-0.8.0-sources.jar!/codegen/templates/ArrowType.java
### java.lang.Exception: Unexpected symbol '#' at word pos: '35' Line: '<#list  arrowTypes.types as type>'

Java indexer failed with and exception.
```Java
/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

<@pp.dropOutputFile />
<@pp.changeOutputFile name="/org/apache/arrow/vector/types/pojo/ArrowType.java" />
<#include "/@includes/license.ftl" />

package org.apache.arrow.vector.types.pojo;

import com.google.flatbuffers.FlatBufferBuilder;

import java.util.Objects;

import org.apache.arrow.flatbuf.Type;

import org.apache.arrow.vector.types.*;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;

/**
 * Arrow types
 * Source code generated using FreeMarker template ${.template_name}
 **/
@JsonTypeInfo(
  use = JsonTypeInfo.Id.NAME,
  include = JsonTypeInfo.As.PROPERTY,
  property = "name")
@JsonSubTypes({
<#list arrowTypes.types as type>
  @JsonSubTypes.Type(value = ArrowType.${type.name?remove_ending("_")}.class, name = "${type.name?remove_ending("_")?lower_case}"),
</#list>
})
public abstract class ArrowType {

  public static abstract class PrimitiveType extends ArrowType {

    private PrimitiveType() {
    }

    @Override
    public boolean isComplex() {
      return false;
    }
  }

  public static abstract class ComplexType extends ArrowType {

    private ComplexType() {
    }

    @Override
    public boolean isComplex() {
      return true;
    }
  }

  public static enum ArrowTypeID {
    <#list arrowTypes.types as type>
    <#assign name = type.name>
    ${name?remove_ending("_")}(Type.${name}),
    </#list>
    NONE(Type.NONE);

    private final byte flatbufType;

    public byte getFlatbufID() {
      return this.flatbufType;
    }

    private ArrowTypeID(byte flatbufType) {
      this.flatbufType = flatbufType;
    }
  }

  @JsonIgnore
  public abstract ArrowTypeID getTypeID();
  @JsonIgnore
  public abstract boolean isComplex();
  public abstract int getType(FlatBufferBuilder builder);
  public abstract <T> T accept(ArrowTypeVisitor<T> visitor);

  /**
   * to visit the ArrowTypes
   * <code>
   *   type.accept(new ArrowTypeVisitor&lt;Type&gt;() {
   *   ...
   *   });
   * </code>
   */
  public static interface ArrowTypeVisitor<T> {
  <#list arrowTypes.types as type>
    T visit(${type.name?remove_ending("_")} type);
  </#list>
  }

  /**
   * to visit the Complex ArrowTypes and bundle Primitive ones in one case
   */
  public static abstract class ComplexTypeVisitor<T> implements ArrowTypeVisitor<T> {

    public T visit(PrimitiveType type) {
      throw new UnsupportedOperationException("Unexpected Primitive type: " + type);
    }

  <#list arrowTypes.types as type>
    <#if !type.complex>
    public final T visit(${type.name?remove_ending("_")} type) {
      return visit((PrimitiveType) type);
    }
    </#if>
  </#list>
  }

  /**
   * to visit the Primitive ArrowTypes and bundle Complex ones under one case
   */
  public static abstract class PrimitiveTypeVisitor<T> implements ArrowTypeVisitor<T> {

    public T visit(ComplexType type) {
      throw new UnsupportedOperationException("Unexpected Complex type: " + type);
    }

  <#list arrowTypes.types as type>
    <#if type.complex>
    public final T visit(${type.name?remove_ending("_")} type) {
      return visit((ComplexType) type);
    }
    </#if>
  </#list>
  }

  <#list arrowTypes.types as type>
  <#assign name = type.name?remove_ending("_")>
  <#assign fields = type.fields>
  public static class ${name} extends <#if type.complex>ComplexType<#else>PrimitiveType</#if> {
    public static final ArrowTypeID TYPE_TYPE = ArrowTypeID.${name};
    <#if type.fields?size == 0>
    public static final ${name} INSTANCE = new ${name}();
    <#else>

    <#list fields as field>
    <#assign fieldType = field.valueType!field.type>
    ${fieldType} ${field.name};
    </#list>

    @JsonCreator
    public ${type.name}(
    <#list type.fields as field>
    <#assign fieldType = field.valueType!field.type>
      @JsonProperty("${field.name}") ${fieldType} ${field.name}<#if field_has_next>, </#if>
    </#list>
    ) {
      <#list type.fields as field>
      this.${field.name} = ${field.name};
      </#list>
    }

    <#list fields as field>
    <#assign fieldType = field.valueType!field.type>
    public ${fieldType} get${field.name?cap_first}() {
      return ${field.name};
    }
    </#list>
    </#if>

    @Override
    public ArrowTypeID getTypeID() {
      return TYPE_TYPE;
    }

    @Override
    public int getType(FlatBufferBuilder builder) {
      <#list type.fields as field>
      <#if field.type == "String">
      int ${field.name} = this.${field.name} == null ? -1 : builder.createString(this.${field.name});
      </#if>
      <#if field.type == "int[]">
      int ${field.name} = this.${field.name} == null ? -1 : org.apache.arrow.flatbuf.${type.name}.create${field.name?cap_first}Vector(builder, this.${field.name});
      </#if>
      </#list>
      org.apache.arrow.flatbuf.${type.name}.start${type.name}(builder);
      <#list type.fields as field>
      <#if field.type == "String" || field.type == "int[]">
      if (this.${field.name} != null) {
        org.apache.arrow.flatbuf.${type.name}.add${field.name?cap_first}(builder, ${field.name});
      }
      <#else>
      org.apache.arrow.flatbuf.${type.name}.add${field.name?cap_first}(builder, this.${field.name}<#if field.valueType??>.getFlatbufID()</#if>);
      </#if>
      </#list>
      return org.apache.arrow.flatbuf.${type.name}.end${type.name}(builder);
    }

    public String toString() {
      return "${name}"
      <#if fields?size != 0>
        + "("
      <#list fields as field>
        +   <#if field.type == "int[]">java.util.Arrays.toString(${field.name})<#else>${field.name}</#if><#if field_has_next> + ", " </#if>
      </#list>
        + ")"
      </#if>
      ;
    }

    @Override
    public int hashCode() {
      return java.util.Arrays.deepHashCode(new Object[] {<#list type.fields as field>${field.name}<#if field_has_next>, </#if></#list>});
    }

    @Override
    public boolean equals(Object obj) {
      if (!(obj instanceof ${name})) {
        return false;
      }
      <#if type.fields?size == 0>
      return true;
      <#else>
      ${type.name} that = (${type.name}) obj;
      return <#list type.fields as field>Objects.deepEquals(this.${field.name}, that.${field.name}) <#if field_has_next>&&<#else>;</#if>
      </#list>
      </#if>
    }

    @Override
    public <T> T accept(ArrowTypeVisitor<T> visitor) {
      return visitor.visit(this);
    }
  }
  </#list>

  public static org.apache.arrow.vector.types.pojo.ArrowType getTypeForField(org.apache.arrow.flatbuf.Field field) {
    switch(field.typeType()) {
    <#list arrowTypes.types as type>
    <#assign name = type.name?remove_ending("_")>
    <#assign nameLower = type.name?lower_case>
    <#assign fields = type.fields>
    case Type.${type.name}: {
      org.apache.arrow.flatbuf.${type.name} ${nameLower}Type = (org.apache.arrow.flatbuf.${type.name}) field.type(new org.apache.arrow.flatbuf.${type.name}());
      <#list type.fields as field>
      <#if field.type == "int[]">
      ${field.type} ${field.name} = new int[${nameLower}Type.${field.name}Length()];
      for (int i = 0; i< ${field.name}.length; ++i) {
        ${field.name}[i] = ${nameLower}Type.${field.name}(i);
      }
      <#else>
      ${field.type} ${field.name} = ${nameLower}Type.${field.name}();
      </#if>
      </#list>
      return new ${name}(<#list type.fields as field><#if field.valueType??>${field.valueType}.fromFlatbufID(${field.name})<#else>${field.name}</#if><#if field_has_next>, </#if></#list>);
    }
    </#list>
    default:
      throw new UnsupportedOperationException("Unsupported type: " + field.typeType());
    }
  }

  public static Int getInt(org.apache.arrow.flatbuf.Field field) {
    org.apache.arrow.flatbuf.Int intType = (org.apache.arrow.flatbuf.Int) field.type(new org.apache.arrow.flatbuf.Int());
    return new Int(intType.bitWidth(), intType.isSigned());
  }
}



```


#### Error stacktrace:

```
scala.meta.internal.mtags.JavaToplevelMtags.unexpectedCharacter(JavaToplevelMtags.scala:352)
	scala.meta.internal.mtags.JavaToplevelMtags.parseToken$1(JavaToplevelMtags.scala:253)
	scala.meta.internal.mtags.JavaToplevelMtags.fetchToken(JavaToplevelMtags.scala:262)
	scala.meta.internal.mtags.JavaToplevelMtags.loop(JavaToplevelMtags.scala:73)
	scala.meta.internal.mtags.JavaToplevelMtags.indexRoot(JavaToplevelMtags.scala:42)
	scala.meta.internal.mtags.MtagsIndexer.index(MtagsIndexer.scala:21)
	scala.meta.internal.mtags.MtagsIndexer.index$(MtagsIndexer.scala:20)
	scala.meta.internal.mtags.JavaToplevelMtags.index(JavaToplevelMtags.scala:18)
	scala.meta.internal.mtags.Mtags.indexWithOverrides(Mtags.scala:74)
	scala.meta.internal.mtags.SymbolIndexBucket.indexSource(SymbolIndexBucket.scala:129)
	scala.meta.internal.mtags.SymbolIndexBucket.addSourceFile(SymbolIndexBucket.scala:108)
	scala.meta.internal.mtags.SymbolIndexBucket.$anonfun$addSourceJar$2(SymbolIndexBucket.scala:74)
	scala.collection.immutable.List.flatMap(List.scala:294)
	scala.meta.internal.mtags.SymbolIndexBucket.$anonfun$addSourceJar$1(SymbolIndexBucket.scala:70)
	scala.meta.internal.io.PlatformFileIO$.withJarFileSystem(PlatformFileIO.scala:77)
	scala.meta.internal.io.FileIO$.withJarFileSystem(FileIO.scala:33)
	scala.meta.internal.mtags.SymbolIndexBucket.addSourceJar(SymbolIndexBucket.scala:68)
	scala.meta.internal.mtags.OnDemandSymbolIndex.$anonfun$addSourceJar$2(OnDemandSymbolIndex.scala:85)
	scala.meta.internal.mtags.OnDemandSymbolIndex.tryRun(OnDemandSymbolIndex.scala:131)
	scala.meta.internal.mtags.OnDemandSymbolIndex.addSourceJar(OnDemandSymbolIndex.scala:84)
	scala.meta.internal.metals.Indexer.indexJar(Indexer.scala:561)
	scala.meta.internal.metals.Indexer.addSourceJarSymbols(Indexer.scala:555)
	scala.meta.internal.metals.Indexer.$anonfun$indexDependencySources$5(Indexer.scala:381)
	scala.collection.IterableOnceOps.foreach(IterableOnce.scala:619)
	scala.collection.IterableOnceOps.foreach$(IterableOnce.scala:617)
	scala.collection.AbstractIterable.foreach(Iterable.scala:935)
	scala.collection.IterableOps$WithFilter.foreach(Iterable.scala:905)
	scala.meta.internal.metals.Indexer.$anonfun$indexDependencySources$1(Indexer.scala:372)
	scala.meta.internal.metals.Indexer.$anonfun$indexDependencySources$1$adapted(Indexer.scala:371)
	scala.collection.IterableOnceOps.foreach(IterableOnce.scala:619)
	scala.collection.IterableOnceOps.foreach$(IterableOnce.scala:617)
	scala.collection.AbstractIterable.foreach(Iterable.scala:935)
	scala.meta.internal.metals.Indexer.indexDependencySources(Indexer.scala:371)
	scala.meta.internal.metals.Indexer.$anonfun$indexWorkspace$19(Indexer.scala:192)
	scala.runtime.java8.JFunction0$mcV$sp.apply(JFunction0$mcV$sp.scala:18)
	scala.meta.internal.metals.TimerProvider.timedThunk(TimerProvider.scala:25)
	scala.meta.internal.metals.Indexer.$anonfun$indexWorkspace$18(Indexer.scala:185)
	scala.meta.internal.metals.Indexer.$anonfun$indexWorkspace$18$adapted(Indexer.scala:181)
	scala.collection.immutable.List.foreach(List.scala:334)
	scala.meta.internal.metals.Indexer.indexWorkspace(Indexer.scala:181)
	scala.meta.internal.metals.Indexer.$anonfun$profiledIndexWorkspace$2(Indexer.scala:57)
	scala.runtime.java8.JFunction0$mcV$sp.apply(JFunction0$mcV$sp.scala:18)
	scala.meta.internal.metals.TimerProvider.timedThunk(TimerProvider.scala:25)
	scala.meta.internal.metals.Indexer.$anonfun$profiledIndexWorkspace$1(Indexer.scala:57)
	scala.runtime.java8.JFunction0$mcV$sp.apply(JFunction0$mcV$sp.scala:18)
	scala.concurrent.Future$.$anonfun$apply$1(Future.scala:687)
	scala.concurrent.impl.Promise$Transformation.run(Promise.scala:467)
	java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1136)
	java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:635)
	java.base/java.lang.Thread.run(Thread.java:833)
```
#### Short summary: 

Java indexer failed with and exception.