error id: jar:file:///C:/Users/Alpha/AppData/Local/Coursier/cache/v1/https/repo1.maven.org/maven2/org/apache/arrow/arrow-vector/0.8.0/arrow-vector-0.8.0-sources.jar!/codegen/templates/UnionReader.java
### java.lang.Exception: Unexpected symbol '#' at word pos: '35' Line: '    <#list  vv.types as type>'

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


import org.apache.arrow.vector.types.Types.MinorType;
import org.apache.arrow.vector.types.pojo.Field;

<@pp.dropOutputFile />
<@pp.changeOutputFile name="/org/apache/arrow/vector/complex/impl/UnionReader.java" />


<#include "/@includes/license.ftl" />

package org.apache.arrow.vector.complex.impl;

<#include "/@includes/vv_imports.ftl" />
/**
 * Source code generated using FreeMarker template ${.template_name}
 */
@SuppressWarnings("unused")
public class UnionReader extends AbstractFieldReader {

  private BaseReader[] readers = new BaseReader[43];
  public UnionVector data;
  
  public UnionReader(UnionVector data) {
    this.data = data;
  }

  public MinorType getMinorType() {
    return TYPES[data.getTypeValue(idx())];
  }

  private static MinorType[] TYPES = new MinorType[43];

  static {
    for (MinorType minorType : MinorType.values()) {
      TYPES[minorType.ordinal()] = minorType;
    }
  }

  @Override
  public Field getField() {
    return data.getField();
  }

  public boolean isSet(){
    return !data.isNull(idx());
  }

  public void read(UnionHolder holder) {
    holder.reader = this;
    holder.isSet = this.isSet() ? 1 : 0;
  }

  public void read(int index, UnionHolder holder) {
    getList().read(index, holder);
  }

  private FieldReader getReaderForIndex(int index) {
    int typeValue = data.getTypeValue(index);
    FieldReader reader = (FieldReader) readers[typeValue];
    if (reader != null) {
      return reader;
    }
    switch (MinorType.values()[typeValue]) {
    case NULL:
      return NullReader.INSTANCE;
    case MAP:
      return (FieldReader) getMap();
    case LIST:
      return (FieldReader) getList();
    <#list vv.types as type>
      <#list type.minor as minor>
        <#assign name = minor.class?cap_first />
        <#assign uncappedName = name?uncap_first/>
        <#if !minor.typeParams?? >
    case ${name?upper_case}:
      return (FieldReader) get${name}();
        </#if>
      </#list>
    </#list>
    default:
      throw new UnsupportedOperationException("Unsupported type: " + MinorType.values()[typeValue]);
    }
  }

  private SingleMapReaderImpl mapReader;

  private MapReader getMap() {
    if (mapReader == null) {
      mapReader = (SingleMapReaderImpl) data.getMap().getReader();
      mapReader.setPosition(idx());
      readers[MinorType.MAP.ordinal()] = mapReader;
    }
    return mapReader;
  }

  private UnionListReader listReader;

  private FieldReader getList() {
    if (listReader == null) {
      listReader = new UnionListReader(data.getList());
      listReader.setPosition(idx());
      readers[MinorType.LIST.ordinal()] = listReader;
    }
    return listReader;
  }

  @Override
  public java.util.Iterator<String> iterator() {
    return getMap().iterator();
  }

  @Override
  public void copyAsValue(UnionWriter writer) {
    writer.data.copyFrom(idx(), writer.idx(), data);
  }

  <#list ["Object", "Integer", "Long", "Boolean",
          "Character", "LocalDateTime", "Double", "Float",
          "Text", "Byte", "Short", "byte[]"] as friendlyType>
  <#assign safeType=friendlyType />
  <#if safeType=="byte[]"><#assign safeType="ByteArray" /></#if>

  @Override
  public ${friendlyType} read${safeType}() {
    return getReaderForIndex(idx()).read${safeType}();
  }

  </#list>

  public int size() {
    return getReaderForIndex(idx()).size();
  }

  <#list vv.types as type>
    <#list type.minor as minor>
      <#assign name = minor.class?cap_first />
      <#assign uncappedName = name?uncap_first/>
      <#assign boxedType = (minor.boxedType!type.boxedType) />
      <#assign javaType = (minor.javaType!type.javaType) />
      <#assign friendlyType = (minor.friendlyType!minor.boxedType!type.boxedType) />
      <#assign safeType=friendlyType />
      <#if safeType=="byte[]"><#assign safeType="ByteArray" /></#if>
      <#if !minor.typeParams?? >

  private ${name}ReaderImpl ${uncappedName}Reader;

  private ${name}ReaderImpl get${name}() {
    if (${uncappedName}Reader == null) {
      ${uncappedName}Reader = new ${name}ReaderImpl(data.get${name}Vector());
      ${uncappedName}Reader.setPosition(idx());
      readers[MinorType.${name?upper_case}.ordinal()] = ${uncappedName}Reader;
    }
    return ${uncappedName}Reader;
  }

  public void read(Nullable${name}Holder holder){
    getReaderForIndex(idx()).read(holder);
  }

  public void copyAsValue(${name}Writer writer){
    getReaderForIndex(idx()).copyAsValue(writer);
  }
      </#if>
    </#list>
  </#list>

  @Override
  public void copyAsValue(ListWriter writer) {
    ComplexCopier.copy(this, (FieldWriter) writer);
  }

  @Override
  public void setPosition(int index) {
    super.setPosition(index);
    for (BaseReader reader : readers) {
      if (reader != null) {
        reader.setPosition(index);
      }
    }
  }

  public FieldReader reader(String name){
    return getMap().reader(name);
  }

  public FieldReader reader() {
    return getList().reader();
  }

  public boolean next() {
    return getReaderForIndex(idx()).next();
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