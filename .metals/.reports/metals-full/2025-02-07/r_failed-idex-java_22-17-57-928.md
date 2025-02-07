error id: jar:file:///C:/Users/Alpha/AppData/Local/Coursier/cache/v1/https/repo1.maven.org/maven2/org/apache/arrow/arrow-vector/0.8.0/arrow-vector-0.8.0-sources.jar!/codegen/templates/ComplexWriters.java
### java.lang.Exception: Unexpected symbol '#' at word pos: '35' Line: '<#list  vv.types as type>'

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
<#list vv.types as type>
<#list type.minor as minor>
<#list ["Nullable"] as mode>
<#assign name = minor.class?cap_first />
<#assign eName = name />
<#assign javaType = (minor.javaType!type.javaType) />
<#assign fields = minor.fields!type.fields />
<#assign friendlyType = (minor.friendlyType!minor.boxedType!type.boxedType) />

<@pp.changeOutputFile name="/org/apache/arrow/vector/complex/impl/${eName}WriterImpl.java" />
<#include "/@includes/license.ftl" />

package org.apache.arrow.vector.complex.impl;

<#include "/@includes/vv_imports.ftl" />

/*
 * This class is generated using FreeMarker on the ${.template_name} template.
 */
@SuppressWarnings("unused")
public class ${eName}WriterImpl extends AbstractFieldWriter {

  final ${name}Vector vector;

  public ${eName}WriterImpl(${name}Vector vector) {
    this.vector = vector;
  }

  @Override
  public Field getField() {
    return vector.getField();
  }

  @Override
  public int getValueCapacity() {
    return vector.getValueCapacity();
  }

  @Override
  public void allocate() {
    vector.allocateNew();
  }

  @Override
  public void close() {
    vector.close();
  }

  @Override
  public void clear() {
    vector.clear();
  }

  @Override
  protected int idx() {
    return super.idx();
  }

  <#if mode == "Repeated">

  public void write(${minor.class?cap_first}Holder h) {
    mutator.addSafe(idx(), h);
    vector.setValueCount(idx()+1);
  }

  public void write(${minor.class?cap_first}Holder h) {
    mutator.addSafe(idx(), h);
    vector.setValueCount(idx()+1);
  }

  public void write${minor.class}(<#list fields as field>${field.type} ${field.name}<#if field_has_next>, </#if></#list>) {
    mutator.addSafe(idx(), <#list fields as field>${field.name}<#if field_has_next>, </#if></#list>);
    vector.setValueCount(idx()+1);
  }

  public void setPosition(int idx) {
    super.setPosition(idx);
    mutator.startNewValue(idx);
  }


  <#else>

  public void write(${minor.class}Holder h) {
    vector.setSafe(idx(), h);
    vector.setValueCount(idx()+1);
  }

  public void write(Nullable${minor.class}Holder h) {
    vector.setSafe(idx(), h);
    vector.setValueCount(idx()+1);
  }

  public void write${minor.class}(<#list fields as field>${field.type} ${field.name}<#if field_has_next>, </#if></#list>) {
    vector.setSafe(idx(), 1<#list fields as field><#if field.include!true >, ${field.name}</#if></#list>);
    vector.setValueCount(idx()+1);
  }

  <#if minor.class == "Decimal">
  public void write${minor.class}(${friendlyType} value) {
    vector.setSafe(idx(), value);
    vector.setValueCount(idx()+1);
  }
  </#if>

  public void writeNull() {
    vector.setNull(idx());
    vector.setValueCount(idx()+1);
  }
  </#if>
}

<@pp.changeOutputFile name="/org/apache/arrow/vector/complex/writer/${eName}Writer.java" />
<#include "/@includes/license.ftl" />

package org.apache.arrow.vector.complex.writer;

<#include "/@includes/vv_imports.ftl" />
/*
 * This class is generated using FreeMarker on the ${.template_name} template.
 */
@SuppressWarnings("unused")
public interface ${eName}Writer extends BaseWriter {
  public void write(${minor.class}Holder h);

  public void write${minor.class}(<#list fields as field>${field.type} ${field.name}<#if field_has_next>, </#if></#list>);
<#if minor.class == "Decimal">

  public void write${minor.class}(${friendlyType} value);
</#if>
}

</#list>
</#list>
</#list>

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